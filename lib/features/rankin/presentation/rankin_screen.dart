import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/theme/app_colors.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_screen_base.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/result_banner.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_info_panel.dart';
import '../domain/rankin_calculator.dart';
import '../domain/rankin_data.dart';

class RankinScreen extends StatefulWidget {
  const RankinScreen({super.key});

  @override
  State<RankinScreen> createState() => _RankinScreenState();
}

class _RankinScreenState extends State<RankinScreen> {
  static const _calculator = RankinCalculator();
  int? _selected;

  RankinResult? get _result =>
      _selected != null ? _calculator.classify(_selected!) : null;

  void _reset() => setState(() => _selected = null);

  Color _colorForScore(int score) {
    if (score <= 2) return AppColors.severityMild;
    if (score <= 4) return AppColors.severityModerate;
    if (score == 5) return AppColors.severitySevere;
    return AppColors.triageBlack;
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    return ToolScreenBase(
      title: 'Escala Rankin Modificada',
      onReset: _reset,
      emptyResultText: 'Selecciona el nivel de dependencia',
      resultWidget: r != null
          ? ResultBanner(
              value: '${r.score}',
              label: r.title,
              subtitle: '${r.independence} para ABVD',
              color: _colorForScore(r.score),
            )
          : null,
      toolBody: ListView(
        padding: const EdgeInsets.all(12),
        children: RankinData.levels.map((level) {
          final isSelected = _selected == level.score;
          final color = _colorForScore(level.score);
          return Card(
            margin: const EdgeInsets.only(bottom: 6),
            color: isSelected ? color.withValues(alpha: 0.15) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isSelected
                  ? BorderSide(color: color, width: 2)
                  : BorderSide.none,
            ),
            child: ListTile(
              onTap: () => setState(() => _selected = level.score),
              leading: CircleAvatar(
                backgroundColor: color,
                child: Text('${level.score}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              title: Text(level.label,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle:
                  level.description != null && level.description!.isNotEmpty
                      ? Text(level.description!,
                          style: const TextStyle(fontSize: 12))
                      : null,
            ),
          );
        }).toList(),
      ),
      infoBody: const ToolInfoPanel(
        sections: RankinData.infoSections,
        references: RankinData.references,
      ),
    );
  }
}
