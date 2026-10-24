import 'package:flutter/widgets.dart';
import 'app_analytics.dart';

class AnalyticsScope extends InheritedNotifier<AppAnalytics> {
  const AnalyticsScope({
    super.key,
    required AppAnalytics analytics,
    required super.child,
  }) : super(notifier: analytics);

  static AppAnalytics? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AnalyticsScope>()?.notifier;
}
