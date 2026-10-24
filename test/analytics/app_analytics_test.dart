import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:emerkit/shared/analytics/app_analytics.dart';
import 'package:emerkit/shared/analytics/analytics_store.dart';
import 'package:emerkit/shared/analytics/analytics_attribution.dart';

class MemoryStore implements AnalyticsStore {
  String? value;
  bool failWrites = false;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String value) async {
    if (failWrites) throw StateError('storage unavailable');
    this.value = value;
  }
}

void main() {
  late MemoryStore store;
  late List<http.Request> requests;
  AppAnalytics make(
          {http.Client? client,
          bool enabled = true,
          Future<String?> Function()? referrer}) =>
      AppAnalytics(
        store: store,
        client: client ??
            MockClient((request) async {
              requests.add(request);
              return http.Response(
                  jsonEncode({
                    'accepted':
                        (jsonDecode(request.body)['events'] as List?)?.length ??
                            0,
                    'erased': 0
                  }),
                  200);
            }),
        collectionEnabled: enabled,
        appVersion: '0.1.19',
        platform: 'android',
        deviceLanguage: 'es-ES',
        allowedToolIds: {'glasgow', 'deamap'},
        referrerReader: referrer,
      );
  setUp(() {
    store = MemoryStore();
    requests = [];
  });

  test('Sin permiso no transmite ni persiste identificadores o herramientas',
      () async {
    final a = make();
    await a.initialize();
    await a.startSession();
    await a.recordToolOpen('glasgow');
    await a.flush();
    expect(a.consent, AnalyticsConsent.pending);
    expect(requests, isEmpty);
    expect(store.value ?? '', isNot(contains('installation_id')));
    expect(a.pendingCount, 0);
  });
  test('Aceptar mide inicio de medición sin inventar una instalación nueva',
      () async {
    final a = make();
    await a.setConsent(true);
    await a.recordToolOpen('glasgow');
    await a.flush();
    final batches = requests
        .where((r) => r.url.path.endsWith('/events'))
        .map((r) => jsonDecode(r.body) as Map<String, dynamic>)
        .toList();
    final names = batches
        .expand((b) => b['events'] as List)
        .map((e) => e['name'])
        .toList();
    expect(
        names, containsAll(['measurement_started', 'app_open', 'tool_open']));
    expect(names, isNot(contains('first_open')));
    expect(
        batches.first['installation_id'], matches(RegExp(r'^[a-f0-9]{32}$')));
    expect(a.pendingCount, 0);
  });
  test('Los payloads rechazan IDs desconocidos y no contienen valores clínicos',
      () async {
    final a = make();
    await a.setConsent(true);
    await a.recordToolOpen('patient_email=value');
    await a.recordToolOpen('glasgow');
    await a.flush();
    for (final r in requests.where((r) => r.url.path.endsWith('/events'))) {
      final b = jsonDecode(r.body) as Map<String, dynamic>;
      expect(b.keys.toSet(), {
        'schema',
        'installation_id',
        'session_id',
        'platform',
        'app_version',
        'device_language',
        'ui_language',
        'attribution',
        'events'
      });
      for (final e in b['events'] as List) {
        expect(
            (e as Map).keys.every((k) => [
                  'id',
                  'name',
                  'tool_id',
                  'occurred_at',
                  'startup_ms'
                ].contains(k)),
            isTrue);
        expect(e['tool_id'], anyOf(isNull, 'glasgow'));
      }
    }
  });
  test('Offline conserva una cola acotada y la reintenta sin duplicar IDs',
      () async {
    var offline = true;
    final delivered = <String>[];
    final a = make(client: MockClient((r) async {
      if (offline) throw http.ClientException('offline');
      final b = jsonDecode(r.body) as Map<String, dynamic>;
      if (r.url.path.endsWith('/events')) {
        final es = b['events'] as List;
        expect(es.length, lessThanOrEqualTo(20));
        delivered.addAll(es.map((e) => e['id'] as String));
      }
      return http.Response(
          jsonEncode({'accepted': (b['events'] as List?)?.length ?? 0}), 200);
    }));
    await a.setConsent(true);
    for (var i = 0; i < 65; i++) {
      await a.recordToolOpen('glasgow');
    }
    await a.flush();
    expect(a.pendingCount, 50);
    offline = false;
    await a.flush();
    expect(a.pendingCount, 0);
    expect(delivered.length, 50);
    expect(delivered.toSet().length, 50);
  });
  test('Rechazar durante envío borra después y no resucita la cola', () async {
    final gate = Completer<http.Response>();
    var held = false;
    final a = make(client: MockClient((r) async {
      requests.add(r);
      if (r.url.path.endsWith('/events') && !held) {
        held = true;
        return gate.future;
      }
      return http.Response('{"accepted":0,"erased":1}', 200);
    }));
    final acceptance = a.setConsent(true);
    while (!held) {
      await Future<void>.delayed(Duration.zero);
    }
    final withdrawal = a.setConsent(false);
    await Future<void>.delayed(Duration.zero);
    gate.complete(http.Response('{"accepted":1}', 200));
    await acceptance;
    await withdrawal;
    expect(a.consent, AnalyticsConsent.declined);
    expect(a.pendingCount, 0);
    expect(requests.last.url.path, endsWith('/erase'));
    await a.recordToolOpen('glasgow');
    await a.flush();
    expect(requests.last.url.path, endsWith('/erase'));
    expect(store.value!, isNot(contains('installation_id')));
  });
  test(
      'Borrado offline queda pendiente y se completa antes de una nueva identidad',
      () async {
    var offline = false;
    final client = MockClient((r) async {
      requests.add(r);
      if (offline) throw http.ClientException('offline');
      return http.Response('{"accepted":0,"erased":1}', 200);
    });
    final a = make(client: client);
    await a.setConsent(true);
    offline = true;
    await a.setConsent(false);
    expect(store.value, contains('pending_erasure'));
    offline = false;
    final b = make(client: client);
    await b.initialize();
    await b.flush();
    expect(store.value!, isNot(contains('pending_erasure')));
    await b.setConsent(true);
    await b.flush();
    expect(b.consent, AnalyticsConsent.granted);
  });
  test('Debug nunca envía aunque se acepte el permiso', () async {
    final a = make(enabled: false);
    await a.setConsent(true);
    await a.recordToolOpen('glasgow');
    await a.flush();
    expect(requests, isEmpty);
  });
  test('Un lote inválido 400 se descarta; 429 se conserva', () async {
    var status = 429;
    final a =
        make(client: MockClient((r) async => http.Response('{}', status)));
    await a.setConsent(true);
    await a.flush();
    expect(a.pendingCount, greaterThan(0));
    status = 400;
    await a.flush();
    expect(a.pendingCount, 0);
  });
  test('Una preferencia corrupta no concede permiso ni envía datos', () async {
    store.value =
        '{"consent":"granted","installation_id":"not-a-valid-id","events": [{"patient":"private"}]}';
    final a = make();
    await a.startSession();
    await a.flush();
    expect(a.consent, AnalyticsConsent.pending);
    expect(requests, isEmpty);
  });
  test('Referrer solo aporta parámetros UTM cerrados y válidos', () async {
    final a = make(
        referrer: () async =>
            'utm_source=youtube&utm_medium=video&utm_campaign=aso_202610&utm_content=es&patient_name=secret');
    await a.setConsent(true);
    await a.flush();
    final b = jsonDecode(requests.first.body) as Map;
    expect(b['attribution'], {
      'source': 'youtube',
      'medium': 'video',
      'campaign': 'aso_202610',
      'content': 'es'
    });
    expect(requests.map((r) => r.body).join(), isNot(contains('patient_name')));
  });
  test('Cola offline mantiene la sesión, idioma y versión originales',
      () async {
    var offline = true;
    final sent = <Map<String, dynamic>>[];
    final client = MockClient((r) async {
      if (offline) throw http.ClientException('offline');
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      sent.add(body);
      return http.Response('{"accepted":0}', 200);
    });
    final a = make(client: client);
    await a.setConsent(true);
    await a.recordToolOpen('glasgow');
    await a.flush();
    final b = AppAnalytics(
        store: store,
        client: client,
        collectionEnabled: true,
        appVersion: '0.1.20',
        platform: 'android',
        deviceLanguage: 'en-US',
        allowedToolIds: {'glasgow'});
    await b.startSession();
    offline = false;
    await b.flush();
    expect(sent.first['app_version'], '0.1.19');
    expect(sent.last['app_version'], '0.1.20');
    expect(sent.first['device_language'], 'es-ES');
    expect(sent.last['device_language'], 'en-US');
    expect(sent.first['session_id'], isNot(sent.last['session_id']));
  });
  test('HTTP 200 sin acuse JSON conserva eventos y borrado para reintentar',
      () async {
    var html = true;
    final a = make(client: MockClient((r) async {
      requests.add(r);
      return http.Response(
          html ? '<html>challenge</html>' : '{"accepted":0,"erased":0}', 200);
    }));
    await a.setConsent(true);
    expect(a.pendingCount, greaterThan(0));
    await a.setConsent(false);
    expect(store.value, contains('pending_erasure'));
    html = false;
    await a.flush();
    expect(store.value, isNot(contains('pending_erasure')));
  });
  test(
      'Reactivar offline conserva permiso y borra antes de crear nueva identidad',
      () async {
    var offline = false;
    final client = MockClient((r) async {
      requests.add(r);
      if (offline) throw http.ClientException('offline');
      return http.Response('{"accepted":0,"erased":0}', 200);
    });
    final a = make(client: client);
    await a.setConsent(true);
    final oldId = jsonDecode(requests.first.body)['installation_id'];
    offline = true;
    await a.setConsent(false);
    await a.setConsent(true);
    final b = make(client: client);
    await b.initialize();
    expect(b.consent, AnalyticsConsent.granted);
    expect(b.canCollect, isFalse);
    requests.clear();
    offline = false;
    await b.startSession();
    expect(requests.first.url.path, endsWith('/erase'));
    expect(requests.last.url.path, endsWith('/events'));
    expect(jsonDecode(requests.last.body)['installation_id'], isNot(oldId));
    expect(b.canCollect, isTrue);
  });
  test('Un fallo guardando rechazo corta la medición y avisa del error',
      () async {
    final a = make();
    await a.setConsent(true);
    requests.clear();
    store.failWrites = true;
    await a.setConsent(false);
    expect(a.consent, AnalyticsConsent.declined);
    expect(a.preferenceError, isTrue);
    await a.recordToolOpen('glasgow');
    await a.flush();
    expect(requests.where((r) => r.url.path.endsWith('/events')), isEmpty);
  });
  test('Cola corrupta conserva la identidad solo para borrarla', () async {
    const original = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
    store.value = jsonEncode({
      'consent': 'granted',
      'installation_id': original,
      'events': [
        {'patient': 'invalid'}
      ]
    });
    final a = make();
    await a.initialize();
    expect(a.consent, AnalyticsConsent.pending);
    await a.setConsent(false);
    expect(requests.single.url.path, endsWith('/erase'));
    expect(jsonDecode(requests.single.body)['installation_id'], original);
  });
  test('Reanudar no inventa llegada a home ni reutiliza arranque anterior',
      () async {
    final a = make();
    await a.recordHomeReady(startupMs: 2500);
    await a.setConsent(true);
    await a.startSession();
    final names = requests
        .where((r) => r.url.path.endsWith('/events'))
        .expand((r) => jsonDecode(r.body)['events'] as List)
        .map((e) => e['name'])
        .toList();
    expect(names.where((n) => n == 'home_ready').length, 1);
    expect(names.where((n) => n == 'app_open').length, 2);
  });
  test('UTM con email, URLs o escapes inválidos no sale del dispositivo', () {
    expect(
        AnalyticsAttribution.fromReferrer(
                'utm_source=victor%40example.com&utm_medium=https%3A%2F%2Fevil.example')
            .toJson(),
        isEmpty);
    expect(AnalyticsAttribution.fromReferrer('%ZZ').toJson(), isEmpty);
    expect(
        AnalyticsAttribution.fromReferrer(
                'utm_source=youtube&utm_campaign=Safe_Campaign')
            .toJson(),
        {'source': 'youtube', 'campaign': 'safe_campaign'});
  });
}
