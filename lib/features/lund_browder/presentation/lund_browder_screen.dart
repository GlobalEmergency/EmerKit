import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/domain/entities/severity.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/theme/app_colors.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_screen_base.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_info_panel.dart';
import '../domain/lund_browder_calculator.dart';
import '../domain/lund_browder_data.dart';

const _burnColors = [Colors.grey, Color(0xFFFFF176), Color(0xFFFFB74D), Color(0xFFE57373)];

class LundBrowderScreen extends StatefulWidget {
  const LundBrowderScreen({super.key});

  @override
  State<LundBrowderScreen> createState() => _LundBrowderScreenState();
}

class _LundBrowderScreenState extends State<LundBrowderScreen> {
  int _selectedAge = 5; // Adult
  final List<int> _burnDegree = List.filled(LundBrowderData.zoneNames.length, 0);

  LundBrowderResult get _result => LundBrowderCalculator.calculate(
        burnDegrees: _burnDegree,
        ageGroupIndex: _selectedAge,
      );

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

  void _reset() {
    setState(() {
      for (int i = 0; i < _burnDegree.length; i++) {
        _burnDegree[i] = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final color = result.totalScq == 0
        ? Colors.grey
        : _colorForSeverity(result.severity.level);

    return ToolScreenBase(
      title: 'Lund-Browder',
      onReset: _reset,
      resultWidget: ResultBanner(
        value: '${result.totalScq.toStringAsFixed(1)}%',
        label: result.severity.label,
        subtitle: 'SCQ - Superficie Corporal Quemada',
        color: color,
      ),
      toolBody: Column(
        children: [
          // Age selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(LundBrowderData.ageGroups.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(LundBrowderData.ageGroups[i]),
                      selected: _selectedAge == i,
                      selectedColor: AppColors.tecnicas,
                      labelStyle: TextStyle(
                        color: _selectedAge == i ? Colors.white : null,
                        fontWeight: _selectedAge == i ? FontWeight.bold : null,
                        fontSize: 12,
                      ),
                      onSelected: (_) => setState(() => _selectedAge = i),
                    ),
                  );
                }),
              ),
            ),
          ),
          // Body zones list
          Expanded(
            child: ListView.builder(
              itemCount: LundBrowderData.zoneNames.length,
              itemBuilder: (context, index) {
                final name = LundBrowderData.zoneNames[index];
                final pct = LundBrowderData.zonePercentages[index][_selectedAge];
                final degree = _burnDegree[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  color: degree > 0 ? _burnColors[degree].withValues(alpha: 0.15) : null,
                  child: ListTile(
                    dense: true,
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(
                      '$pct% \u00b7 ${LundBrowderData.burnLabels[degree]}',
                      style: TextStyle(fontSize: 12, color: _burnColors[degree]),
                    ),
                    trailing: SizedBox(
                      width: 160,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: List.generate(4, (d) {
                          return GestureDetector(
                            onTap: () => setState(() => _burnDegree[index] = d),
                            child: Container(
                              width: 36,
                              height: 36,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: degree == d
                                    ? _burnColors[d]
                                    : _burnColors[d].withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: degree == d
                                    ? Border.all(color: Colors.black26, width: 2)
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  '$d',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: degree == d ? Colors.white : Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Legend
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (d) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    children: [
                      Container(width: 12, height: 12, color: _burnColors[d]),
                      const SizedBox(width: 4),
                      Text(LundBrowderData.burnLabels[d],
                          style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
      infoBody: ToolInfoPanel(
        sections: LundBrowderData.infoSections,
        references: LundBrowderData.references,
      ),
    );
  }
}
