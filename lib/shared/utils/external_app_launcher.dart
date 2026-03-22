import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

/// Lanza una app externa. Si no esta instalada, abre Play Store.
class ExternalAppLauncher {
  /// Intenta abrir la app por su package name usando un Android intent.
  /// Si no esta instalada, abre su pagina en Play Store.
  static Future<void> launchOrStore({
    required String packageName,
    String? appScheme, // e.g., 'deamap://' si la app tiene deep link
  }) async {
    // En Android, intentar abrir la app via intent con el package name
    if (Platform.isAndroid) {
      final intentUri = Uri.parse(
        'intent://#Intent;package=$packageName;end',
      );
      if (await canLaunchUrl(intentUri)) {
        await launchUrl(intentUri);
        return;
      }
    }

    // Intentar abrir la app con su scheme personalizado
    if (appScheme != null) {
      final appUri = Uri.parse(appScheme);
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    // Si no se puede abrir, ir a Play Store
    final storeUrl = Uri.parse(
      'https://play.google.com/store/apps/details?id=$packageName',
    );
    await launchUrl(storeUrl, mode: LaunchMode.externalApplication);
  }
}
