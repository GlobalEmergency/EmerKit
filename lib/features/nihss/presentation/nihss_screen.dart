import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/domain/entities/severity.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/theme/app_colors.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_screen_base.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/result_banner.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_info_panel.dart';
import '../domain/nihss_calculator.dart';
import '../domain/nihss_data.dart';

class NihssScreen extends StatefulWidget {
  const NihssScreen({super.key});

  @override
  State<NihssScreen> createState() => _NihssScreenState();
}

class _NihssScreenState extends State<NihssScreen> {
  static const _calculator = NihssCalculator();
  late List<int> _scores = List.filled(NihssData.items.length, 0);

  NihssResult get _result => _calculator.calculate(_scores);

  void _reset() => setState(() => _scores = List.filled(NihssData.items.length, 0));

  @override
  Widget build(BuildContext context) {
    final r = _result;
    return ToolScreenBase(
      title: 'Escala NIHSS',
      onReset: _reset,
      resultWidget: ResultBanner(
        value: '${r.total}',
        label: r.severity.label,
        color: r.severity.level.color,
      ),
      toolBody: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: NihssData.items.length,
        itemBuilder: (context, index) {
          final item = NihssData.items[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 4),
            child: ExpansionTile(
              title: Text(item.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              trailing: CircleAvatar(
                radius: 14,
                backgroundColor: _scores[index] > 0 ? AppColors.severitySevere : AppColors.severityMild,
                child: Text('${_scores[index]}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              children: List.generate(item.options.length, (optIndex) {
                return RadioListTile<int>(
                  title: Text(item.options[optIndex].label, style: const TextStyle(fontSize: 12)),
                  value: item.options[optIndex].score,
                  groupValue: _scores[index],
                  dense: true,
                  onChanged: (v) => setState(() => _scores[index] = v!),
                );
              }),
            ),
          );
        },
      ),
      infoBody: const ToolInfoPanel(
        sections: NihssData.infoSections,
        references: NihssData.references,
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
