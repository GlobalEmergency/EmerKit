import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/domain/entities/severity.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/theme/app_colors.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_screen_base.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/result_banner.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_info_panel.dart';
import '../domain/temperature_classifier.dart';
import '../domain/hipotermia_data.dart';

class HipotermiaScreen extends StatefulWidget {
  const HipotermiaScreen({super.key});

  @override
  State<HipotermiaScreen> createState() => _HipotermiaScreenState();
}

class _HipotermiaScreenState extends State<HipotermiaScreen> {
  double _temperature = 36.5;

  TemperatureResult get _result =>
      TemperatureClassifier.classifyHypothermia(_temperature);

  Color _colorForSeverity(SeverityLevel level) {
    switch (level) {
      case SeverityLevel.mild:
        return AppColors.severityMild;
      case SeverityLevel.moderate:
        return AppColors.severityModerate;
      case SeverityLevel.severe:
        return AppColors.severitySevere;
    }
  }

  String get _gradeRange {
    if (_temperature >= 35) return '>= 35 C';
    if (_temperature >= 32) return '32 - 35 C';
    if (_temperature >= 28) return '28 - 32 C';
    return '< 28 C';
  }

  void _reset() => setState(() => _temperature = 36.5);

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final color = _colorForSeverity(result.severity.level);

    return ToolScreenBase(
      title: 'Hipotermia',
      onReset: _reset,
      resultWidget: ResultBanner(
        value: '${_temperature.toStringAsFixed(1)} C',
        label: result.label,
        subtitle: _gradeRange,
        color: color,
      ),
      toolBody: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Temperature slider
          Card(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Temperatura corporal',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('25 C', style: TextStyle(fontSize: 12)),
                      Expanded(
                        child: Slider(
                          value: _temperature,
                          min: 25,
                          max: 37,
                          divisions: 24,
                          activeColor: color,
                          label: '${_temperature.toStringAsFixed(1)} C',
                          onChanged: (v) => setState(() => _temperature = v),
                        ),
                      ),
                      const Text('37 C', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Current grade detail card
          _buildGradeCard(
            'Hipotermia ${result.label} ($_gradeRange)',
            color,
            result.symptoms,
            result.treatment,
          ),
        ],
      ),
      infoBody: const ToolInfoPanel(
        sections: HipotermiaData.infoSections,
        references: HipotermiaData.references,
      ),
    );
  }

  Widget _buildGradeCard(
    String title,
    Color color,
    List<String> symptoms,
    List<String> treatment,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                title,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16, color: color),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Sintomas:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...symptoms.map((s) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('\u2022 ',
                          style: TextStyle(fontSize: 14)),
                      Expanded(
                          child:
                              Text(s, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            const Text('Tratamiento:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...treatment.map((t) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('\u2022 ',
                          style: TextStyle(fontSize: 14)),
                      Expanded(
                          child:
                              Text(t, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
