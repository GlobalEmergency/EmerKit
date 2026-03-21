import 'package:url_launcher/url_launcher.dart';

/// Lanza una app externa. Si no está instalada, abre Play Store.
class ExternalAppLauncher {
  /// Intenta abrir la app por su package name.
  /// Si no está instalada, abre su página en Play Store.
  static Future<void> launchOrStore({
    required String packageName,
    String? appScheme, // e.g., 'deamap://' si la app tiene deep link
  }) async {
    // Intentar abrir la app directamente
    if (appScheme != null) {
      final appUri = Uri.parse(appScheme);
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri);
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
