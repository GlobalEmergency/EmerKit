import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'analytics_attribution.dart';
import 'analytics_store.dart';

enum AnalyticsConsent { pending, granted, declined }

class AppAnalytics extends ChangeNotifier {
  AppAnalytics({
    required AnalyticsStore store,
    required http.Client client,
    required String platform,
    required this.deviceLanguage,
    required this.allowedToolIds,
    String? appVersion,
    bool collectionEnabled = kReleaseMode,
    Future<String?> Function()? referrerReader,
  })  : platform = platform.toLowerCase(),
        _store = store,
        _client = client,
        _version = appVersion,
        _collectionEnabled = collectionEnabled,
        _referrerReader = referrerReader;

  static final _base =
      Uri.https('emerkit.globalemergency.online', '/wp-json/emerkit/v1/');
  static const _eventNames = {
    'measurement_started',
    'app_open',
    'home_ready',
    'tool_open',
    'external_tool_open'
  };
  static final _identifier = RegExp(r'^[a-f0-9]{32}$');
  final AnalyticsStore _store;
  final http.Client _client;
  final bool _collectionEnabled;
  final Future<String?> Function()? _referrerReader;
  final String platform;
  final String deviceLanguage;
  final Set<String> allowedToolIds;
  final Stopwatch _startup = Stopwatch()..start();
  String? _version;
  AnalyticsConsent _consent = AnalyticsConsent.pending;
  String? _installationId;
  String? _sessionId;
  String? _pendingErasure;
  bool _measured = false;
  bool _referrerAttempted = false;
  bool _disposed = false;
  bool _initialized = false;
  bool _preferenceError = false;
  int? _homeReadyMs;
  String? _homeSession;
  AnalyticsAttribution _attribution = const AnalyticsAttribution.empty();
  final List<Map<String, dynamic>> _events = [];
  Future<void>? _initialization;
  Future<void>? _sending;
  Future<void> _writes = Future.value();

  AnalyticsConsent get consent => _consent;
  bool get initialized => _initialized;
  bool get preferenceError => _preferenceError;
  bool get supported => const {'android', 'ios', 'web'}.contains(platform);
  bool get canCollect =>
      _collectionEnabled &&
      supported &&
      _consent == AnalyticsConsent.granted &&
      _pendingErasure == null;
  int get pendingCount => _events.length;
  int get startupMilliseconds => _startup.elapsedMilliseconds.clamp(0, 120000);

  String _id() {
    final random = Random.secure();
    return List.generate(
            16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'))
        .join();
  }

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  Future<void> initialize() => _initialization ??= _load();
  Future<void> _load() async {
    try {
      if (_version == null) {
        final version =
            jsonDecode(await rootBundle.loadString('assets/version.json'))
                as Map;
        _version = version['version'] as String;
      }
      if (!RegExp(r'^\d{1,4}\.\d{1,4}\.\d{1,4}$').hasMatch(_version ?? '')) {
        throw const FormatException('Invalid app version');
      }
      final raw = await _store.read();
      if (raw != null) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        final decision = data['consent'];
        if (decision == 'declined') _consent = AnalyticsConsent.declined;
        final erasure = data['pending_erasure'];
        if (erasure is String && _identifier.hasMatch(erasure)) {
          _pendingErasure = erasure;
        }
        if (decision == 'granted') {
          final id = data['installation_id'];
          if (id != null && (id is! String || !_identifier.hasMatch(id))) {
            throw const FormatException('Invalid analytics identity');
          }
          if (id == null && _pendingErasure == null) {
            throw const FormatException('Missing analytics identity');
          }
          _installationId = id as String?;
          final saved =
              (data['events'] as List? ?? []).cast<Map<String, dynamic>>();
          if (saved.any((e) => !_validEvent(e))) {
            throw const FormatException('Invalid analytics queue');
          }
          if (id == null && saved.isNotEmpty) {
            throw const FormatException('Queue without analytics identity');
          }
          _installationId = id;
          _consent = AnalyticsConsent.granted;
          _measured = data['measured'] == true;
          _attribution = AnalyticsAttribution.fromJson(
              Map<String, dynamic>.from(data['attribution'] as Map? ?? {}));
          _events.addAll(saved.take(50));
        }
      }
    } catch (_) {
      _pendingErasure ??= _installationId;
      _consent = AnalyticsConsent.pending;
      _installationId = null;
      _events.clear();
    }
    _initialized = true;
    _changed();
  }

  bool _validEvent(Map<String, dynamic> event) {
    if (event.keys.any((k) => !const {
          'id',
          'name',
          'tool_id',
          'occurred_at',
          'startup_ms',
          '_session_id',
          '_app_version',
          '_device_language',
          '_attribution'
        }.contains(k))) {
      return false;
    }
    if (!_identifier
        .hasMatch(event['id'] is String ? event['id'] as String : '')) {
      return false;
    }
    if (!_eventNames.contains(event['name'])) return false;
    if (event['_session_id'] is! String ||
        !_identifier.hasMatch(event['_session_id'] as String)) {
      return false;
    }
    if (event['_app_version'] is! String ||
        !RegExp(r'^\d{1,4}\.\d{1,4}\.\d{1,4}$')
            .hasMatch(event['_app_version'] as String)) {
      return false;
    }
    if (event['_device_language'] is! String ||
        !RegExp(r'^[a-zA-Z]{2,8}(?:-[a-zA-Z0-9]{1,8})*$')
            .hasMatch(event['_device_language'] as String) ||
        (event['_device_language'] as String).length > 35) {
      return false;
    }
    final attribution = event['_attribution'];
    if (attribution is! Map ||
        attribution.keys.any((k) =>
            !const {'source', 'medium', 'campaign', 'content'}.contains(k))) {
      return false;
    }
    if (AnalyticsAttribution.fromJson(Map<String, dynamic>.from(attribution))
            .toJson()
            .length !=
        attribution.length) {
      return false;
    }
    final toolEvent =
        event['name'] == 'tool_open' || event['name'] == 'external_tool_open';
    if (toolEvent != (event['tool_id'] is String) ||
        (toolEvent && !allowedToolIds.contains(event['tool_id']))) {
      return false;
    }
    final time = event['occurred_at'];
    if (time is! String ||
        !time.endsWith('Z') ||
        DateTime.tryParse(time) == null) {
      return false;
    }
    final ms = event['startup_ms'];
    return ms == null ||
        (const {'app_open', 'home_ready'}.contains(event['name']) &&
            ms is int &&
            ms >= 0 &&
            ms <= 120000);
  }

  Future<void> _serial(Future<void> Function() action) {
    final next = _writes.then((_) => action());
    _writes = next.catchError((Object _) {});
    return next;
  }

  Future<void> _save() async {
    await _store.write(jsonEncode({
      'consent': _consent.name,
      if (_installationId != null) 'installation_id': _installationId,
      if (_pendingErasure != null) 'pending_erasure': _pendingErasure,
      'measured': _measured,
      'attribution': _attribution.toJson(),
      'events': _events,
    }));
  }

  Future<void> setConsent(bool granted) async {
    await initialize();
    try {
      await _serial(() async {
        _preferenceError = false;
        _consent =
            granted ? AnalyticsConsent.granted : AnalyticsConsent.declined;
        if (!granted) {
          _pendingErasure ??= _installationId;
          _installationId = null;
          _sessionId = null;
          _events.clear();
          _measured = false;
          _attribution = const AnalyticsAttribution.empty();
          _referrerAttempted = false;
        }
        await _save();
        _changed();
      });
      final sending = _sending;
      if (sending != null) await sending;
      await flush();
      if (granted && _consent == AnalyticsConsent.granted) await startSession();
    } catch (_) {
      _preferenceError = true;
      _consent = granted ? AnalyticsConsent.pending : AnalyticsConsent.declined;
      _installationId = null;
      _sessionId = null;
      _events.clear();
      _changed();
    }
  }

  Future<void> startSession() async {
    await initialize();
    if (!canCollect) await flush();
    if (!canCollect) return;
    try {
      if (!_referrerAttempted && _referrerReader != null) {
        _referrerAttempted = true;
        try {
          final referrer =
              await _referrerReader().timeout(const Duration(seconds: 2));
          if (referrer != null && canCollect) {
            _attribution = AnalyticsAttribution.fromReferrer(referrer);
          }
        } catch (_) {/* Attribution must never prevent opening a tool. */}
      }
      await _serial(() async {
        if (!canCollect) return;
        _installationId ??= _id();
        _sessionId = _id();
        if (!_measured) {
          _add('measurement_started');
          _measured = true;
        }
        _add('app_open');
        if (_homeReadyMs != null) {
          _add('home_ready', startupMs: _homeReadyMs);
          _homeSession = _sessionId;
          _homeReadyMs = null;
        }
        await _save();
      });
      await flush();
    } catch (_) {/* Optional measurement cannot break the app. */}
  }

  Future<void> recordHomeReady({required int startupMs}) async {
    _homeReadyMs = startupMs.clamp(0, 120000);
    await initialize();
    if (!canCollect || _sessionId == null || _homeSession == _sessionId) return;
    _homeSession = _sessionId;
    final measuredMs = _homeReadyMs;
    _homeReadyMs = null;
    await _record('home_ready', startupMs: measuredMs);
  }

  Future<void> recordToolOpen(String toolId, {bool external = false}) async {
    if (!allowedToolIds.contains(toolId)) return;
    await _record(external ? 'external_tool_open' : 'tool_open',
        toolId: toolId);
  }

  void _add(String name, {String? toolId, int? startupMs}) {
    _events.add({
      'id': _id(),
      'name': name,
      '_session_id': _sessionId,
      '_app_version': _version,
      '_device_language': deviceLanguage,
      '_attribution': _attribution.toJson(),
      'occurred_at': DateTime.now().toUtc().toIso8601String(),
      if (toolId != null) 'tool_id': toolId,
      if (startupMs != null) 'startup_ms': startupMs,
    });
    if (_events.length > 50) _events.removeRange(0, _events.length - 50);
  }

  Future<void> _record(String name, {String? toolId, int? startupMs}) async {
    await initialize();
    if (!canCollect || _installationId == null || _sessionId == null) return;
    try {
      await _serial(() async {
        if (!canCollect) return;
        _add(name, toolId: toolId, startupMs: startupMs);
        await _save();
      });
      unawaited(flush());
    } catch (_) {/* A storage failure must not interrupt care. */}
  }

  Future<void> flush() {
    final active = _sending;
    if (active != null) return active;
    final task = _send();
    _sending = task;
    return task.whenComplete(() {
      if (identical(_sending, task)) _sending = null;
    });
  }

  Future<void> _send() async {
    await initialize();
    if (!_collectionEnabled || !supported) return;
    try {
      final pending = _pendingErasure;
      if (pending != null) {
        final response = await _client
            .post(_base.resolve('erase'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'installation_id': pending}))
            .timeout(const Duration(seconds: 3));
        if (response.statusCode != 200 || !_acknowledged(response, 'erased')) {
          return;
        }
        await _serial(() async {
          if (_pendingErasure == pending) {
            _pendingErasure = null;
            await _save();
          }
        });
      }
      for (var batchNumber = 0; batchNumber < 3; batchNumber++) {
        List<Map<String, dynamic>> batch = [];
        String? identity;
        Map<String, dynamic>? body;
        await _serial(() async {
          if (!canCollect ||
              _installationId == null ||
              _sessionId == null ||
              _version == null) {
            return;
          }
          final cutoff =
              DateTime.now().toUtc().subtract(const Duration(days: 7));
          _events.removeWhere((e) =>
              DateTime.parse(e['occurred_at'] as String).isBefore(cutoff));
          if (_events.isEmpty) return;
          final first = _events.first;
          batch = _events
              .takeWhile((e) =>
                  e['_session_id'] == first['_session_id'] &&
                  e['_app_version'] == first['_app_version'] &&
                  e['_device_language'] == first['_device_language'] &&
                  jsonEncode(e['_attribution']) ==
                      jsonEncode(first['_attribution']))
              .take(20)
              .toList();
          identity = _installationId;
          body = {
            'schema': 1,
            'installation_id': identity,
            'session_id': first['_session_id'],
            'platform': platform,
            'app_version': first['_app_version'],
            'device_language': first['_device_language'],
            'ui_language': 'es',
            'attribution': first['_attribution'],
            'events': batch
                .map((e) => {
                      for (final entry in e.entries)
                        if (!entry.key.startsWith('_')) entry.key: entry.value
                    })
                .toList()
          };
        });
        if (body == null) return;
        final response = await _client
            .post(_base.resolve('events'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(body))
            .timeout(const Duration(seconds: 3));
        final drop = (response.statusCode == 200 &&
                _acknowledged(response, 'accepted', maximum: batch.length)) ||
            response.statusCode == 400 ||
            response.statusCode == 413;
        if (!drop) return;
        await _serial(() async {
          if (_installationId != identity) return;
          final ids = batch.map((e) => e['id']).toSet();
          _events.removeWhere((e) => ids.contains(e['id']));
          await _save();
        });
      }
    } catch (_) {
      /* Keep retryable events until the next launch or interaction. */
    }
  }

  bool _acknowledged(http.Response response, String field, {int? maximum}) {
    try {
      final value = (jsonDecode(response.body) as Map<String, dynamic>)[field];
      return value is int &&
          value >= 0 &&
          (maximum == null || value <= maximum);
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _client.close();
    super.dispose();
  }
}
