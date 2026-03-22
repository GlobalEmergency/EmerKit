import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/domain/entities/severity.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/theme/app_colors.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_screen_base.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/result_banner.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_info_panel.dart';
import '../domain/tep_calculator.dart';
import '../domain/tep_data.dart';

class TepScreen extends StatefulWidget {
  const TepScreen({super.key});

  @override
  State<TepScreen> createState() => _TepScreenState();
}

class _TepScreenState extends State<TepScreen> {
  static const _calculator = TepCalculator();
  bool? _appearance, _breathing, _circulation;

  static const _icons = [Icons.child_care, Icons.air, Icons.favorite];

  bool get _allSelected =>
      _appearance != null && _breathing != null && _circulation != null;

  List<bool?> get _values => [_appearance, _breathing, _circulation];

  void _setValue(int index, bool value) => setState(() {
    if (index == 0) {
      _appearance = value;
    } else if (index == 1) {
      _breathing = value;
    } else {
      _circulation = value;
    }
  });

  void _reset() => setState(() {
    _appearance = null; _breathing = null; _circulation = null;
  });

  @override
  Widget build(BuildContext context) {
    final result = _allSelected
        ? _calculator.calculate(
            appearance: _appearance,
            breathing: _breathing,
            circulation: _circulation,
          )
        : null;

    return ToolScreenBase(
      title: 'TEP',
      onReset: _reset,
      emptyResultText: 'Evalua los 3 lados del triangulo',
      resultWidget: result != null
          ? ResultBanner(
              value: result.diagnosis,
              label: result.abnormalCount == 0
                  ? 'Sin alteraciones'
                  : '${result.abnormalCount} lado${result.abnormalCount > 1 ? 's' : ''} alterado${result.abnormalCount > 1 ? 's' : ''}',
              color: result.severity.level.color,
            )
          : null,
      toolBody: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: TepData.sides.length,
        itemBuilder: (context, index) {
          final side = TepData.sides[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(_icons[index], color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(side.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 4),
                    Text(side.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _ToggleButton(
                        label: 'Normal', isSelected: _values[index] == true,
                        color: AppColors.severityMild, onTap: () => _setValue(index, true),
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: _ToggleButton(
                        label: 'Anormal', isSelected: _values[index] == false,
                        color: AppColors.severitySevere, onTap: () => _setValue(index, false),
                      )),
                    ]),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      infoBody: const ToolInfoPanel(
        sections: TepData.infoSections,
        references: TepData.references,
      ),
    );
  }
}

extension _SeverityColor on SeverityLevel {
  Color get color {
    switch (this) {
      case SeverityLevel.mild: return AppColors.severityMild;
      case SeverityLevel.moderate: return AppColors.severityModerate;
      case SeverityLevel.severe: return AppColors.severitySevere;
    }
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label, required this.isSelected,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? color : Colors.grey.shade200,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(label, textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black54)),
        ),
      ),
    );
  }
}
