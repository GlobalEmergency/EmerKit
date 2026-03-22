import 'package:flutter/material.dart';
import 'info_bottom_sheet.dart';

/// Widget base para todas las herramientas interactivas de la app.
///
/// Patrón: [resultWidget] arriba (siempre visible) + [toolBody] debajo.
/// Botón de info en AppBar abre BottomSheet con [infoBody].
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: 'Info',
            onPressed: () =>
                showInfoSheet(context, title: title, child: infoBody),
          ),
          if (onReset != null)
            IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Reiniciar',
                onPressed: onReset),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
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
            Expanded(child: toolBody),
          ],
        ),
      ),
    );
  }
}
