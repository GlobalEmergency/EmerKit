import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final List<Widget>? extraActions;

  const ToolScreenBase({
    super.key,
    required this.title,
    this.resultWidget,
    this.emptyResultText = 'Selecciona los valores para obtener el resultado',
    required this.toolBody,
    required this.infoBody,
    this.onReset,
    this.extraActions,
  });

  void _confirmReset(BuildContext context) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reiniciar'),
        content: const Text(
          '\u00bfDescartar todos los valores y empezar de nuevo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              onReset!();
              HapticFeedback.lightImpact();
            },
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (extraActions != null) ...extraActions!,
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
              onPressed: () => _confirmReset(context),
            ),
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
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.grey.shade500,
                        ),
                  ),
                ),
            Expanded(child: toolBody),
          ],
        ),
      ),
    );
  }
}
