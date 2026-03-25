import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

/// Lanza una app externa. Si no esta instalada, abre la store correspondiente.
class ExternalAppLauncher {
  /// Intenta abrir la app por su package name (Android) o scheme (iOS).
  /// Si no esta instalada, redirige a la store correspondiente via [fallbackUrl].
  ///
  /// [fallbackUrl] es una URL universal que detecta la plataforma y redirige
  /// a la store correcta (ej: https://deamap.es/open?source=emerkit).
  static Future<void> launchOrStore({
    required String packageName,
    String? appScheme, // e.g., 'deamap://open?source=emerkit'
    String? fallbackUrl, // e.g., 'https://deamap.es/open?source=emerkit'
  }) async {
    // En Android, intentar abrir la app via intent con el package name
    if (Platform.isAndroid) {
      if (appScheme != null) {
        // Construir Intent URL a partir del scheme personalizado.
        // Ej: 'deamap://open?source=emerkit' → intent://open?source=emerkit#Intent;scheme=deamap;package=...;end
        final schemeUri = Uri.parse(appScheme);
        final intentUri = Uri.parse(
          'intent://${schemeUri.host}${schemeUri.path}'
          '${schemeUri.query.isNotEmpty ? '?${schemeUri.query}' : ''}'
          '#Intent'
          ';scheme=${schemeUri.scheme}'
          ';package=$packageName'
          ';end',
        );
        if (await canLaunchUrl(intentUri)) {
          await launchUrl(intentUri);
          return;
        }
      }

      // Fallback: intent basico por package name
      final intentUri = Uri.parse(
        'intent://#Intent;package=$packageName;end',
      );
      if (await canLaunchUrl(intentUri)) {
        await launchUrl(intentUri);
        return;
      }
    }

    // En iOS, intentar abrir con scheme personalizado
    if (Platform.isIOS && appScheme != null) {
      final appUri = Uri.parse(appScheme);
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    // Fallback: URL universal (detecta plataforma y redirige a la store)
    if (fallbackUrl != null) {
      final url = Uri.parse(fallbackUrl);
      await launchUrl(url, mode: LaunchMode.externalApplication);
      return;
    }

    // Ultimo recurso: Play Store directo
    final storeUrl = Uri.parse(
      'https://play.google.com/store/apps/details?id=$packageName',
    );
    await launchUrl(storeUrl, mode: LaunchMode.externalApplication);
  }
}
