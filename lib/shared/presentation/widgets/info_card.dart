import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final Color? titleColor;

  const InfoCard({
    super.key,
    required this.title,
    required this.content,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = titleColor ?? Theme.of(context).colorScheme.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
