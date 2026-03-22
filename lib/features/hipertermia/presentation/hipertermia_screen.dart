import 'package:flutter/material.dart';
import 'package:emerkit/shared/domain/entities/severity.dart';
import 'package:emerkit/shared/presentation/theme/app_colors.dart';
import 'package:emerkit/shared/presentation/widgets/tool_screen_base.dart';
import 'package:emerkit/shared/presentation/widgets/result_banner.dart';
import 'package:emerkit/shared/presentation/widgets/tool_info_panel.dart';
import 'package:emerkit/shared/domain/temperature_classifier.dart';
import '../domain/hipertermia_data.dart';

class HipertermiaScreen extends StatefulWidget {
  const HipertermiaScreen({super.key});

  @override
  State<HipertermiaScreen> createState() => _HipertermiaScreenState();
}

class _HipertermiaScreenState extends State<HipertermiaScreen> {
  double _temperature = 37.0;

  TemperatureResult get _result =>
      TemperatureClassifier.classifyHyperthermia(_temperature);

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

  void _reset() => setState(() => _temperature = 37.0);

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final color = _colorForSeverity(result.severity.level);

    return ToolScreenBase(
      title: 'Hipertermia',
      onReset: _reset,
      resultWidget: ResultBanner(
        value: '${_temperature.toStringAsFixed(1)} C',
        label: result.label,
        color: color,
      ),
      toolBody: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Temperature slider
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.thermostat,
                          size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text('Temperatura corporal',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('${_temperature.toStringAsFixed(1)} C',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: color)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: _temperature,
                    min: 36.0,
                    max: 43.0,
                    divisions: 14,
                    activeColor: color,
                    label: '${_temperature.toStringAsFixed(1)} C',
                    onChanged: (v) => setState(() => _temperature = v),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('36 C',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600)),
                      Text('43 C',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Current grade card
          _buildGradeCard(
            result.label,
            color,
            result.symptoms,
            result.treatment,
          ),
        ],
      ),
      infoBody: const ToolInfoPanel(
        sections: HipertermiaData.infoSections,
        references: HipertermiaData.references,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16, color: color)),
            ),
            const SizedBox(height: 12),
            const Text('Sintomas:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...symptoms.map((s) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('\u2022 '),
                      Expanded(
                          child: Text(s, style: const TextStyle(fontSize: 13))),
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
                      const Text('\u2022 '),
                      Expanded(
                          child: Text(t, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
