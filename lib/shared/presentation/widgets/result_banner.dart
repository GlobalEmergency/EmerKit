import 'package:flutter/material.dart';
import 'package:emerkit/shared/domain/entities/severity.dart';

/// Banner de resultado que se muestra siempre en la parte superior de cada herramienta.
/// Muestra un valor grande, una etiqueta y opcionalmente un subtítulo.
/// Opcionalmente muestra un icono de severidad para accesibilidad (daltonismo).
class ResultBanner extends StatelessWidget {
  final String value;
  final String label;
  final String? subtitle;
  final Color color;
  final SeverityLevel? severityLevel;

  const ResultBanner({
    super.key,
    required this.value,
    required this.label,
    this.subtitle,
    required this.color,
    this.severityLevel,
  });

  IconData? get _severityIcon {
    switch (severityLevel) {
      case SeverityLevel.mild:
        return Icons.check_circle_outline;
      case SeverityLevel.moderate:
        return Icons.warning_amber_rounded;
      case SeverityLevel.severe:
        return Icons.error_outline;
      case null:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final icon = _severityIcon;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      color: color.withValues(alpha: 0.12),
      child: Column(
        children: [
          Text(
            value,
            style: tt.displayLarge!.copyWith(color: color),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: tt.titleSmall!.copyWith(color: color),
              ),
            ],
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: tt.bodySmall!.copyWith(
                  color: color.withValues(alpha: 0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
