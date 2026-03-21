import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/theme/app_colors.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  // TODO: Reemplazar con tu Google Form real
  // TODO: Reemplazar con tu Google Form real cuando lo crees
  static const _googleFormUrl = 'https://forms.gle/PLACEHOLDER';
  static const _emailAddress = 'info@globalemergency.online';
  static const _githubIssuesUrl = 'https://github.com/GlobalEmergency/NavajaSuizaSanitaria/issues';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sugerencias')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 8),
            const Icon(Icons.lightbulb_outline, size: 48, color: AppColors.accent),
            const SizedBox(height: 12),
            const Text(
              '¿Echas en falta alguna herramienta?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Ayúdanos a mejorar. Puedes solicitar nuevas calculadoras, escalas, protocolos o cualquier funcionalidad que te sea útil en tu trabajo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
            ),
            const SizedBox(height: 28),

            // Option 1: Google Form
            _buildOption(
              icon: Icons.assignment,
              color: AppColors.accent,
              title: 'Formulario de sugerencias',
              subtitle: 'Rápido y anónimo. No necesitas cuenta.',
              buttonText: 'Abrir formulario',
              onTap: () => _launch(_googleFormUrl),
            ),
            const SizedBox(height: 12),

            // Option 2: Email
            _buildOption(
              icon: Icons.email_outlined,
              color: AppColors.primary,
              title: 'Enviar por email',
              subtitle: _emailAddress,
              buttonText: 'Escribir email',
              onTap: () => _launch(
                'mailto:$_emailAddress?subject=${Uri.encodeComponent('Sugerencia - Navaja Suiza Sanitaria')}&body=${Uri.encodeComponent('Hola,\n\nMe gustaría sugerir:\n\n')}',
              ),
            ),
            const SizedBox(height: 12),

            // Option 3: GitHub
            _buildOption(
              icon: Icons.code,
              color: const Color(0xFF333333),
              title: 'GitHub Issues',
              subtitle: 'Si tienes cuenta de GitHub, abre un issue directamente.',
              buttonText: 'Abrir en GitHub',
              onTap: () => _launch(_githubIssuesUrl),
            ),

            const SizedBox(height: 24),
            Card(
              color: AppColors.primary.withValues(alpha: 0.08),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: AppColors.accent, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Cada sugerencia nos ayuda a construir una herramienta mejor para todos los profesionales sanitarios.',
                        style: TextStyle(fontSize: 12, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launch(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
