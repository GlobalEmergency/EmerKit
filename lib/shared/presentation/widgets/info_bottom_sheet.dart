import 'package:flutter/material.dart';

/// Muestra un BottomSheet deslizable con contenido informativo.
/// Reutilizable por ToolScreenBase y por pantallas estáticas.
void showInfoSheet(
  BuildContext context, {
  required String title,
  required Widget child,
}) {
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
                Icon(Icons.menu_book,
                    color: Theme.of(context).colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
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
              child: child,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Botón de info para usar en AppBar.actions de pantallas que NO usan ToolScreenBase.
Widget buildInfoAction(BuildContext context, String title, Widget infoContent) {
  return IconButton(
    icon: const Icon(Icons.menu_book_outlined),
    tooltip: 'Info',
    onPressed: () => showInfoSheet(context, title: title, child: infoContent),
  );
}
