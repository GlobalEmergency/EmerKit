import 'dart:async';
import 'dart:convert';

import 'package:emerkit/app.dart';
import 'package:emerkit/shared/analytics/app_analytics.dart';
import 'package:emerkit/shared/analytics/analytics_store.dart';
import 'package:emerkit/shared/presentation/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _MemoryStore implements AnalyticsStore {
  String? value;
  Completer<void>? gate;
  bool failWrite = false;
  @override
  Future<String?> read() async {
    await gate?.future;
    return value;
  }

  @override
  Future<void> write(String value) async {
    if (failWrite) throw StateError('Storage unavailable');
    this.value = value;
  }
}

void main() {
  late _MemoryStore store;
  late AppAnalytics analytics;
  late List<Map<String, dynamic>> payloads;

  setUp(() {
    store = _MemoryStore();
    payloads = [];
  });

  void createAnalytics() {
    analytics = AppAnalytics(
      store: store,
      client: MockClient((request) async {
        payloads.add(jsonDecode(request.body) as Map<String, dynamic>);
        return http.Response('{"accepted":20}', 200);
      }),
      platform: 'android',
      appVersion: '0.1.19',
      deviceLanguage: 'es-ES',
      allowedToolIds: {'glasgow', 'rcp_rithm', 'deamap'},
      collectionEnabled: true,
    );
  }

  tearDown(() => analytics.dispose());

  Future<void> openHome(WidgetTester tester) async {
    createAnalytics();
    appRouter.go('/home');
    await tester.pumpWidget(EmerKitApp(analytics: analytics));
    await tester.pumpAndSettle();
  }

  testWidgets('rechazar sigue permitiendo abrir herramientas sin enviar datos',
      (tester) async {
    tester.view.platformDispatcher.localeTestValue = const Locale('es', 'ES');
    addTearDown(tester.view.platformDispatcher.clearLocaleTestValue);
    await openHome(tester);
    expect(find.text('Permitir'), findsOneWidget);
    expect(find.text('No, gracias'), findsOneWidget);
    expect(payloads, isEmpty);
    await tester.tap(find.text('No, gracias'));
    await tester.pumpAndSettle();
    expect(analytics.consent, AnalyticsConsent.declined);
    expect(find.text('Permitir'), findsNothing);
    await tester.tap(find.text('RCP'));
    await tester.pumpAndSettle();
    expect(appRouter.routerDelegate.currentConfiguration.last.matchedLocation,
        '/rcp-rithm');
    expect(payloads, isEmpty);
  });

  testWidgets('consentimiento en inglés y retirada accesible desde Acerca de',
      (tester) async {
    tester.view.platformDispatcher.localeTestValue = const Locale('en', 'GB');
    addTearDown(tester.view.platformDispatcher.clearLocaleTestValue);
    await openHome(tester);
    expect(find.text('Allow'), findsOneWidget);
    expect(find.text('No, thanks'), findsOneWidget);
    await tester.tap(find.text('Allow'));
    await tester.pumpAndSettle();
    expect(analytics.consent, AnalyticsConsent.granted);
    expect(payloads.where((p) => p.containsKey('events')), isNotEmpty);
    expect(payloads.first['ui_language'], 'es');
    appRouter.go('/about');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(SwitchListTile));
    expect(find.text('Privacy policy'), findsOneWidget);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(analytics.consent, AnalyticsConsent.declined);
    expect(payloads.last.keys, contains('installation_id'));
    expect(payloads.last.keys, isNot(contains('events')));
  });

  testWidgets('el almacenamiento lento no bloquea home ni las herramientas',
      (tester) async {
    store.gate = Completer<void>();
    createAnalytics();
    appRouter.go('/home');
    await tester.pumpWidget(EmerKitApp(analytics: analytics));
    await tester.pumpAndSettle();
    expect(find.text('RCP'), findsOneWidget);
    await tester.tap(find.text('RCP'));
    await tester.pumpAndSettle();
    expect(appRouter.routerDelegate.currentConfiguration.last.matchedLocation,
        '/rcp-rithm');
    store.gate!.complete();
    await tester.pumpAndSettle();
    expect(payloads, isEmpty);
  });

  testWidgets('una ruta resuelta cuenta una apertura sin repetir en rebuild',
      (tester) async {
    await openHome(tester);
    await analytics.setConsent(true);
    await tester.pumpAndSettle();
    payloads.clear();
    appRouter.go('/glasgow?patient=never_collect');
    await tester.pumpAndSettle();
    await tester.pumpWidget(EmerKitApp(analytics: analytics));
    await tester.pumpAndSettle();
    final events =
        payloads.expand((p) => p['events'] as List? ?? []).cast<Map>();
    expect(events.where((e) => e['name'] == 'tool_open').length, 1);
    expect(jsonEncode(payloads), isNot(contains('patient')));
    expect(jsonEncode(payloads), isNot(contains('never_collect')));
  });
  testWidgets('solo volver de segundo plano inicia otra sesión',
      (tester) async {
    await openHome(tester);
    await analytics.setConsent(true);
    await tester.pumpAndSettle();
    payloads.clear();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(payloads, isEmpty);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    final events =
        payloads.expand((p) => p['events'] as List? ?? []).cast<Map>();
    expect(events.where((e) => e['name'] == 'app_open').length, 1);
  });
  testWidgets(
      'DEA registra una herramienta externa y conserva acceso a su enlace',
      (tester) async {
    final launchedUrls = <String>[];
    const channel = MethodChannel('plugins.flutter.io/url_launcher');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
        (call) async {
      if (call.method == 'launch') {
        launchedUrls.add((call.arguments as Map)['url'] as String);
      }
      return true;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));
    await openHome(tester);
    await analytics.setConsent(true);
    await tester.pumpAndSettle();
    payloads.clear();
    await tester.tap(find.text('DEA Cercano'));
    await tester.pumpAndSettle();
    final events =
        payloads.expand((p) => p['events'] as List? ?? []).cast<Map>();
    expect(
        events
            .where((e) => e['name'] == 'external_tool_open')
            .single['tool_id'],
        'deamap');
    expect(events.where((e) => e['name'] == 'tool_open'), isEmpty);
    expect(launchedUrls.single, 'https://deamap.es/open?source=emerkit');
  });
  testWidgets('si guardar falla se avisa y las herramientas siguen disponibles',
      (tester) async {
    tester.view.platformDispatcher.localeTestValue = const Locale('es', 'ES');
    addTearDown(tester.view.platformDispatcher.clearLocaleTestValue);
    await openHome(tester);
    store.failWrite = true;
    await tester.tap(find.text('Permitir'));
    await tester.pumpAndSettle();
    expect(
        find.text('No se ha podido guardar tu elección. Inténtalo de nuevo.'),
        findsOneWidget);
    expect(analytics.preferenceError, isTrue);
    expect(payloads, isEmpty);
    expect(find.text('RCP'), findsOneWidget);
  });
}
