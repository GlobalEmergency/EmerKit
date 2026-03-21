import 'package:flutter/material.dart';

/// Banner de resultado que se muestra siempre en la parte superior de cada herramienta.
/// Muestra un valor grande, una etiqueta y opcionalmente un subtítulo.
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
