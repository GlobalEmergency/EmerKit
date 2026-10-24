import 'dart:async';

import 'package:flutter/material.dart';
import 'package:emerkit/shared/analytics/app_analytics.dart';
import 'package:emerkit/shared/analytics/analytics_scope.dart';
import 'package:url_launcher/url_launcher.dart';

class AnalyticsConsentBanner extends StatelessWidget {
  const AnalyticsConsentBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = AnalyticsScope.maybeOf(context);
    if (analytics == null ||
        !analytics.supported ||
        !analytics.initialized ||
        analytics.consent != AnalyticsConsent.pending) {
      return const SizedBox.shrink();
    }
    final english = _english(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(english ? 'Help improve EmerKit' : 'Ayuda a mejorar EmerKit',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(english
                ? 'Optional analytics about app and tool use and campaign source, with a random identifier. Never clinical data. You can change your choice in About.'
                : 'Analítica opcional sobre uso de la app, herramientas y origen de campaña, con un identificador aleatorio. Nunca datos clínicos. Puedes cambiar tu elección en Acerca de.'),
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () =>
                      unawaited(_setConsent(context, analytics, true)),
                  child: Text(english ? 'Allow' : 'Permitir'),
                ),
                TextButton(
                  onPressed: () =>
                      unawaited(_setConsent(context, analytics, false)),
                  child: Text(english ? 'No, thanks' : 'No, gracias'),
                ),
                const _PrivacyLink(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AnalyticsConsentSettings extends StatelessWidget {
  const AnalyticsConsentSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = AnalyticsScope.maybeOf(context);
    if (analytics == null || !analytics.supported || !analytics.initialized) {
      return const SizedBox.shrink();
    }
    final english = _english(context);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: Text(english ? 'Optional analytics' : 'Analítica opcional'),
            subtitle: Text(english
                ? 'App and tool use and campaign source, with a random identifier. Never clinical data. Turning this off requests deletion of your analytics history when connected.'
                : 'Uso de la app, herramientas y origen de campaña, con un identificador aleatorio. Nunca datos clínicos. Al desactivar se solicita borrar tu historial de analítica cuando haya conexión.'),
            value: analytics.consent == AnalyticsConsent.granted,
            onChanged: (value) =>
                unawaited(_setConsent(context, analytics, value)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: _PrivacyLink(),
          ),
        ],
      ),
    );
  }
}

Future<void> _setConsent(
    BuildContext context, AppAnalytics analytics, bool granted) async {
  await analytics.setConsent(granted);
  if (!context.mounted || !analytics.preferenceError) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(_english(context)
        ? 'Your choice could not be saved. Please try again.'
        : 'No se ha podido guardar tu elección. Inténtalo de nuevo.'),
  ));
}

bool _english(BuildContext context) =>
    View.of(context).platformDispatcher.locale.languageCode != 'es';

class _PrivacyLink extends StatelessWidget {
  const _PrivacyLink();

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: () => launchUrl(
          Uri.parse('https://www.globalemergency.online/privacidad-emerkit'),
          mode: LaunchMode.externalApplication,
        ),
        child: Text(
            _english(context) ? 'Privacy policy' : 'Política de privacidad'),
      );
}
