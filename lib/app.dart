import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'features/home/presentation/tool_registry.dart';
import 'shared/analytics/analytics_scope.dart';
import 'shared/analytics/app_analytics.dart';
import 'shared/analytics/analytics_store.dart';
import 'shared/presentation/theme/app_theme.dart';
import 'shared/presentation/router/app_router.dart';

class EmerKitApp extends StatefulWidget {
  const EmerKitApp({super.key, this.analytics});

  final AppAnalytics? analytics;

  @override
  State<EmerKitApp> createState() => _EmerKitAppState();
}

class _EmerKitAppState extends State<EmerKitApp> with WidgetsBindingObserver {
  late final AppAnalytics _analytics;
  late final Future<void> _initialSession;
  String? _lastPath;
  bool _homeReady = false;
  bool _backgrounded = false;

  @override
  void initState() {
    super.initState();
    _analytics = widget.analytics ??
        AppAnalytics(
          store: PreferencesAnalyticsStore(),
          client: http.Client(),
          platform: kIsWeb ? 'web' : defaultTargetPlatform.name,
          deviceLanguage:
              WidgetsBinding.instance.platformDispatcher.locale.toLanguageTag(),
          allowedToolIds: ToolRegistry.tools.map((tool) => tool.id).toSet(),
          referrerReader:
              !kIsWeb && defaultTargetPlatform == TargetPlatform.android
                  ? () => const MethodChannel(
                          'online.globalemergency.emerkit/attribution')
                      .invokeMethod<String>('installReferrer')
                  : null,
        );
    _initialSession = _analytics.startSession();
    unawaited(_initialSession);
    WidgetsBinding.instance.addObserver(this);
    appRouter.routerDelegate.addListener(_routeChanged);
    _routeChanged();
  }

  void _routeChanged() {
    final route = appRouter.routerDelegate.currentConfiguration;
    if (route.error != null) return;
    if (route.isEmpty) {
      return;
    }
    final path = route.last.matchedLocation;
    if (path == _lastPath) return;
    _lastPath = path;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          appRouter.routerDelegate.currentConfiguration.last.matchedLocation !=
              path) {
        return;
      }
      if (path == '/home' && !_homeReady) {
        _homeReady = true;
        unawaited(_analytics.recordHomeReady(
            startupMs: _analytics.startupMilliseconds));
      }
      for (final tool in ToolRegistry.tools) {
        if (!tool.isExternal && tool.route == path) {
          unawaited(_recordTool(tool.id));
          break;
        }
      }
    });
  }

  Future<void> _recordTool(String id) async {
    await _initialSession;
    if (mounted) await _analytics.recordToolOpen(id);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _backgrounded = true;
      unawaited(_analytics.flush());
    } else if (state == AppLifecycleState.resumed && _backgrounded) {
      _backgrounded = false;
      unawaited(_analytics.startSession());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    appRouter.routerDelegate.removeListener(_routeChanged);
    if (widget.analytics == null) _analytics.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnalyticsScope(
      analytics: _analytics,
      child: MaterialApp.router(
        title: 'EmerKit',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: appRouter,
        builder: (context, child) {
          final data = MediaQuery.of(context);
          final shortSide = data.size.shortestSide;
          // Tablets have shortestSide >= 600dp
          // Scale text proportionally, composing with user preference
          double extraScale;
          if (shortSide >= 720) {
            extraScale = 1.3;
          } else if (shortSide >= 600) {
            extraScale = 1.2;
          } else {
            extraScale = 1.0;
          }
          if (extraScale == 1.0) return child!;
          // Compose: user's textScaler * our tablet factor
          final userScale = data.textScaler.scale(1.0);
          return MediaQuery(
            data: data.copyWith(
              textScaler: TextScaler.linear(userScale * extraScale),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
