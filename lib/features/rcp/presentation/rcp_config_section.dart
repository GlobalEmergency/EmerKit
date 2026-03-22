import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/theme/app_colors.dart';
import '../domain/rcp_session.dart';

/// Config section for RCP mode (SVB/SVA) and ventilation toggle.
///
/// Shows a compact chip layout while running, and a full layout when stopped.
class RcpConfigSection extends StatelessWidget {
  const RcpConfigSection({
    super.key,
    required this.isRunning,
    required this.mode,
    required this.ventilationEnabled,
    required this.onModeChanged,
    required this.onVentilationChanged,
  });

  final bool isRunning;
  final RcpMode mode;
  final bool ventilationEnabled;
  final ValueChanged<RcpMode> onModeChanged;
  final ValueChanged<bool> onVentilationChanged;

  @override
  Widget build(BuildContext context) {
    if (isRunning) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Wrap(
          spacing: 6,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            ChoiceChip(
              label: const Text('SVB'),
              selected: mode == RcpMode.svb,
              selectedColor: AppColors.soporteVital,
              labelStyle: TextStyle(
                color: mode == RcpMode.svb ? Colors.white : null,
                fontSize: 12,
              ),
              onSelected: (_) => onModeChanged(RcpMode.svb),
              visualDensity: VisualDensity.compact,
            ),
            ChoiceChip(
              label: const Text('SVA'),
              selected: mode == RcpMode.sva,
              selectedColor: AppColors.soporteVital,
              labelStyle: TextStyle(
                color: mode == RcpMode.sva ? Colors.white : null,
                fontSize: 12,
              ),
              onSelected: (_) => onModeChanged(RcpMode.sva),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('30:2'),
              selected: ventilationEnabled,
              selectedColor: AppColors.valoracion.withValues(alpha: 0.3),
              onSelected: onVentilationChanged,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SegmentedButton<RcpMode>(
            segments: const [
              ButtonSegment(value: RcpMode.svb, label: Text('SVB')),
              ButtonSegment(value: RcpMode.sva, label: Text('SVA')),
            ],
            selected: {mode},
            onSelectionChanged: (selected) => onModeChanged(selected.first),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SwitchListTile(
            title: const Text(
              'Parada para ventilaciones (30:2)',
              style: TextStyle(fontSize: 14),
            ),
            value: ventilationEnabled,
            onChanged: onVentilationChanged,
            activeThumbColor: AppColors.soporteVital,
            dense: true,
          ),
        ),
      ],
    );
  }
}
