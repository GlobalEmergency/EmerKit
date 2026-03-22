import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/domain/entities/severity.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/theme/app_colors.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_screen_base.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/result_banner.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_info_panel.dart';
import '../domain/cincinnati_calculator.dart';
import '../domain/cincinnati_data.dart';

class CincinnatiScreen extends StatefulWidget {
  const CincinnatiScreen({super.key});

  @override
  State<CincinnatiScreen> createState() => _CincinnatiScreenState();
}

class _CincinnatiScreenState extends State<CincinnatiScreen> {
  static const _calculator = CincinnatiCalculator();

  bool? _facialDroop;
  bool? _armDrift;
  bool? _speech;

  bool get _isComplete =>
      _facialDroop != null && _armDrift != null && _speech != null;

  CincinnatiResult? get _result {
    if (!_isComplete) return null;
    return _calculator.calculate(
      facialDroop: _facialDroop!,
      armDrift: _armDrift!,
      speech: _speech!,
    );
  }

  void _reset() => setState(() {
        _facialDroop = null;
        _armDrift = null;
        _speech = null;
      });

  @override
  Widget build(BuildContext context) {
    final r = _result;
    return ToolScreenBase(
      title: 'Escala Cincinnati',
      onReset: _reset,
      emptyResultText: 'Evalua los 3 signos para obtener el resultado',
      resultWidget: r != null
          ? ResultBanner(
              value: '${r.score}/3',
              label: r.suspectedStroke ? 'SOSPECHA DE ICTUS' : 'SIN SOSPECHA',
              subtitle: r.suspectedStroke ? 'Activar Codigo Ictus' : null,
              color: r.severity.level.color,
            )
          : null,
      toolBody: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildItem(
            'Asimetria facial',
            Icons.face,
            'Pida al paciente que sonria',
            'Ambos lados se mueven igual',
            'Un lado no se mueve',
            _facialDroop,
            (v) => setState(() => _facialDroop = v),
          ),
          const SizedBox(height: 8),
          _buildItem(
            'Fuerza en brazos',
            Icons.front_hand,
            'Extienda brazos 10 segundos',
            'Ambos brazos se mueven igual',
            'Un brazo cae o no se mueve',
            _armDrift,
            (v) => setState(() => _armDrift = v),
          ),
          const SizedBox(height: 8),
          _buildItem(
            'Habla',
            Icons.record_voice_over,
            'Repita una frase',
            'Pronuncia correctamente',
            'Arrastra palabras o no habla',
            _speech,
            (v) => setState(() => _speech = v),
          ),
        ],
      ),
      infoBody: const ToolInfoPanel(
        sections: CincinnatiData.infoSections,
        references: CincinnatiData.references,
      ),
    );
  }

  Widget _buildItem(
    String title,
    IconData icon,
    String instruction,
    String normalText,
    String abnormalText,
    bool? value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ]),
            const SizedBox(height: 4),
            Text(instruction,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _optionButton(
                  'Normal',
                  normalText,
                  value == false,
                  AppColors.severityMild,
                  () => onChanged(false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _optionButton(
                  'Anormal',
                  abnormalText,
                  value == true,
                  AppColors.severitySevere,
                  () => onChanged(true),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _optionButton(
    String label,
    String description,
    bool selected,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: selected ? color : Colors.grey)),
            Text(description,
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

extension _SeverityColor on SeverityLevel {
  Color get color {
    switch (this) {
      case SeverityLevel.mild:
        return AppColors.severityMild;
      case SeverityLevel.moderate:
        return AppColors.severityModerate;
      case SeverityLevel.severe:
        return AppColors.severitySevere;
    }
  }
}
