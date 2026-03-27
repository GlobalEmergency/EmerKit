import 'package:flutter/material.dart';

/// Reusable helper to show an info bottom sheet for static reference screens.
///
/// Call [buildInfoAction] to get an IconButton for AppBar actions.
/// Call [showScreenInfo] to open the modal bottom sheet directly.

IconButton buildInfoAction(
    BuildContext context, String title, List<Widget> children) {
  return IconButton(
    icon: const Icon(Icons.menu_book_outlined),
    tooltip: 'Información',
    onPressed: () => showScreenInfo(context, title, children),
  );
}

void showScreenInfo(BuildContext context, String title, List<Widget> children) {
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
      builder: (context, sc) => Column(
        children: [
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                const Icon(Icons.menu_book, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              controller: sc,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Convenience builder for an info card section used inside the bottom sheet.
Widget buildInfoCard(String title, String body) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(builder: (context) {
            return Text(title, style: Theme.of(context).textTheme.titleSmall);
          }),
          const SizedBox(height: 8),
          Builder(builder: (context) {
            return Text(body,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(height: 1.5));
          }),
        ],
      ),
    ),
  );
}

/// Convenience builder for a references card at the end of the info sheet.
Widget buildReferencesCard(List<String> references) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(builder: (context) {
            final tt = Theme.of(context).textTheme;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.library_books,
                        size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('Referencias', style: tt.titleSmall),
                  ],
                ),
                const SizedBox(height: 8),
                ...references.map(
                  (ref) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('\u2022 ', style: tt.bodyMedium),
                        Expanded(
                          child: Text(
                            ref,
                            style: tt.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    ),
  );
}
