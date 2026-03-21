import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Widget base para todas las herramientas de la app.
///
/// Patrón: [resultWidget] arriba (siempre visible) + [toolBody] debajo.
/// Botón de info en el AppBar abre un BottomSheet con [infoBody].
class ToolScreenBase extends StatelessWidget {
  final String title;
  final Widget? resultWidget;
  final String emptyResultText;
  final Widget toolBody;
  final Widget infoBody;
  final VoidCallback? onReset;

  const ToolScreenBase({
    super.key,
    required this.title,
    this.resultWidget,
    this.emptyResultText = 'Selecciona los valores para obtener el resultado',
    required this.toolBody,
    required this.infoBody,
    this.onReset,
  });

  void _showInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  const Icon(Icons.menu_book, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: infoBody,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: 'Info',
            onPressed: () => _showInfo(context),
          ),
          if (onReset != null)
            IconButton(icon: const Icon(Icons.refresh), tooltip: 'Reiniciar', onPressed: onReset),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Result widget - always visible
            resultWidget ??
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: Colors.grey.withValues(alpha: 0.05),
                  child: Text(
                    emptyResultText,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ),
            // Tool body
            Expanded(child: toolBody),
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar el resultado con valor grande, etiqueta y color.
class ResultBanner extends StatelessWidget {
  final String value;
  final String label;
  final String? subtitle;
  final Color color;

  const ResultBanner({
    super.key,
    required this.value,
    required this.label,
    this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      color: color.withValues(alpha: 0.12),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.7)),
              ),
            ),
        ],
      ),
    );
  }
}
