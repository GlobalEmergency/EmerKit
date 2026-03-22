import 'package:flutter/material.dart';
import 'package:emerkit/shared/domain/entities/severity.dart';
import 'package:emerkit/shared/presentation/theme/app_colors.dart';
import 'package:emerkit/shared/presentation/widgets/tool_screen_base.dart';
import 'package:emerkit/shared/presentation/widgets/result_banner.dart';
import 'package:emerkit/shared/presentation/widgets/scored_item_selector.dart';
import 'package:emerkit/shared/presentation/widgets/tool_info_panel.dart';
import '../domain/glasgow_calculator.dart';
import '../domain/glasgow_data.dart';

class GlasgowScreen extends StatefulWidget {
  const GlasgowScreen({super.key});

  @override
  State<GlasgowScreen> createState() => _GlasgowScreenState();
}

class _GlasgowScreenState extends State<GlasgowScreen> {
  static const _calculator = GlasgowCalculator();
  int _eye = 4, _verbal = 5, _motor = 6;

  GlasgowResult get _result =>
      _calculator.calculate(eye: _eye, verbal: _verbal, motor: _motor);

  void _reset() => setState(() {
        _eye = 4;
        _verbal = 5;
        _motor = 6;
      });

  @override
  Widget build(BuildContext context) {
    final r = _result;
    return ToolScreenBase(
      title: 'Escala de Glasgow',
      onReset: _reset,
      resultWidget: ResultBanner(
        value: '${r.total}',
        label: r.severity.label,
        subtitle: 'O: ${r.eye}  V: ${r.verbal}  M: ${r.motor}',
        color: r.severity.level.color,
      ),
      toolBody: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ScoredItemSelector(
            title: 'Ocular (O)',
            icon: Icons.remove_red_eye,
            items: GlasgowData.eyeResponses,
            selectedScore: _eye,
            onChanged: (v) => setState(() => _eye = v),
          ),
          ScoredItemSelector(
            title: 'Verbal (V)',
            icon: Icons.record_voice_over,
            items: GlasgowData.verbalResponses,
            selectedScore: _verbal,
            onChanged: (v) => setState(() => _verbal = v),
          ),
          ScoredItemSelector(
            title: 'Motor (M)',
            icon: Icons.front_hand,
            items: GlasgowData.motorResponses,
            selectedScore: _motor,
            onChanged: (v) => setState(() => _motor = v),
          ),
        ],
      ),
      infoBody: const ToolInfoPanel(
        sections: GlasgowData.infoSections,
        references: GlasgowData.references,
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
