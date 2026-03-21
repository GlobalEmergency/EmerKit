import 'package:flutter/material.dart';
import '../../domain/entities/scored_item.dart';

class ScoredItemSelector extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<ScoredItem> items;
  final int selectedScore;
  final ValueChanged<int> onChanged;
  final Color? accentColor;

  const ScoredItemSelector({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    required this.selectedScore,
    required this.onChanged,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? Theme.of(context).colorScheme.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ...items.map((item) {
            final isSelected = item.score == selectedScore;
            return ListTile(
              dense: true,
              selected: isSelected,
              selectedTileColor: color.withValues(alpha: 0.08),
              title: Text(item.label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : null)),
              subtitle: item.description != null ? Text(item.description!, style: const TextStyle(fontSize: 11)) : null,
              trailing: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${item.score}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey),
                  ),
                ),
              ),
              onTap: () => onChanged(item.score),
            );
          }),
        ],
      ),
    );
  }
}
