import 'package:flutter/material.dart';
import 'package:emerkit/shared/domain/entities/severity.dart';
import 'package:emerkit/shared/presentation/theme/app_colors.dart';
import 'package:emerkit/shared/presentation/widgets/tool_screen_base.dart';
import 'package:emerkit/shared/presentation/widgets/result_banner.dart';
import 'package:emerkit/shared/presentation/widgets/scored_item_selector.dart';
import 'package:emerkit/shared/presentation/widgets/tool_info_panel.dart';
import '../domain/apgar_calculator.dart';
import '../domain/apgar_data.dart';

class ApgarScreen extends StatefulWidget {
  const ApgarScreen({super.key});

  @override
  State<ApgarScreen> createState() => _ApgarScreenState();
}

class _ApgarScreenState extends State<ApgarScreen> {
  static const _calculator = ApgarCalculator();
  int _appearance = 2,
      _pulse = 2,
      _grimace = 2,
      _activity = 2,
      _respiration = 2;

  ApgarResult get _result => _calculator.calculate(
        appearance: _appearance,
        pulse: _pulse,
        grimace: _grimace,
        activity: _activity,
        respiration: _respiration,
      );

  void _reset() => setState(() {
        _appearance = 2;
        _pulse = 2;
        _grimace = 2;
        _activity = 2;
        _respiration = 2;
      });

  @override
  Widget build(BuildContext context) {
    final r = _result;
    return ToolScreenBase(
      title: 'Test de Apgar',
      onReset: _reset,
      resultWidget: ResultBanner(
        value: '${r.total}',
        label: r.severity.label,
        subtitle:
            'A: ${r.appearance}  P: ${r.pulse}  G: ${r.grimace}  A: ${r.activity}  R: ${r.respiration}',
        color: r.severity.level.color,
        severityLevel: r.severity.level,
      ),
      toolBody: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ScoredItemSelector(
            title: 'Apariencia (A)',
            icon: Icons.palette,
            items: ApgarData.appearanceResponses,
            selectedScore: _appearance,
            onChanged: (v) => setState(() => _appearance = v),
          ),
          ScoredItemSelector(
            title: 'Pulso (P)',
            icon: Icons.favorite,
            items: ApgarData.pulseResponses,
            selectedScore: _pulse,
            onChanged: (v) => setState(() => _pulse = v),
          ),
          ScoredItemSelector(
            title: 'Gesticulacion (G)',
            icon: Icons.sentiment_satisfied,
            items: ApgarData.grimaceResponses,
            selectedScore: _grimace,
            onChanged: (v) => setState(() => _grimace = v),
          ),
          ScoredItemSelector(
            title: 'Actividad (A)',
            icon: Icons.fitness_center,
            items: ApgarData.activityResponses,
            selectedScore: _activity,
            onChanged: (v) => setState(() => _activity = v),
          ),
          ScoredItemSelector(
            title: 'Respiracion (R)',
            icon: Icons.air,
            items: ApgarData.respirationResponses,
            selectedScore: _respiration,
            onChanged: (v) => setState(() => _respiration = v),
          ),
        ],
      ),
      infoBody: const ToolInfoPanel(
        sections: ApgarData.infoSections,
        references: ApgarData.references,
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
