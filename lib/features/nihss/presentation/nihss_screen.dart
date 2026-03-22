import 'package:flutter/material.dart';
import 'package:emerkit/shared/domain/entities/severity.dart';
import 'package:emerkit/shared/presentation/theme/app_colors.dart';
import 'package:emerkit/shared/presentation/widgets/tool_screen_base.dart';
import 'package:emerkit/shared/presentation/widgets/result_banner.dart';
import 'package:emerkit/shared/presentation/widgets/tool_info_panel.dart';
import '../domain/nihss_calculator.dart';
import '../domain/nihss_data.dart';

class NihssScreen extends StatefulWidget {
  const NihssScreen({super.key});

  @override
  State<NihssScreen> createState() => _NihssScreenState();
}

class _NihssScreenState extends State<NihssScreen> {
  static const _calculator = NihssCalculator();
  List<int> _scores = List.filled(NihssData.items.length, 0);
  int _expandedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _tileKeys =
      List.generate(NihssData.items.length, (_) => GlobalKey());

  NihssResult get _result => _calculator.calculate(_scores);

  void _reset() => setState(() {
        _scores = List.filled(NihssData.items.length, 0);
        _expandedIndex = 0;
      });

  void _selectAndAdvance(int index, int value) {
    setState(() {
      _scores[index] = value;
      if (index < NihssData.items.length - 1) {
        _expandedIndex = index + 1;
      }
    });

    // Scroll to next item after a short delay for the animation
    if (index < NihssData.items.length - 1) {
      Future.delayed(const Duration(milliseconds: 300), () {
        final key = _tileKeys[index + 1];
        if (key.currentContext != null) {
          Scrollable.ensureVisible(
            key.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        itemCount: NihssData.items.length,
        itemBuilder: (context, index) {
          final item = NihssData.items[index];
          final isExpanded = index == _expandedIndex;
          return Card(
            key: _tileKeys[index],
            margin: const EdgeInsets.only(bottom: 4),
            child: ExpansionTile(
              // Key includes _expandedIndex so tile rebuilds with correct state
              key: ValueKey('nihss_${index}_exp_$_expandedIndex'),
              initiallyExpanded: isExpanded,
              onExpansionChanged: (expanded) {
                if (expanded) {
                  setState(() => _expandedIndex = index);
                }
              },
              title: Row(
                children: [
                  Text(
                    '${index + 1}. ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isExpanded
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: CircleAvatar(
                radius: 14,
                backgroundColor: _scores[index] > 0
                    ? AppColors.severitySevere
                    : AppColors.severityMild,
                child: Text(
                  '${_scores[index]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              children: [
                RadioGroup<int>(
                  groupValue: _scores[index],
                  onChanged: (v) => _selectAndAdvance(index, v!),
                  child: Column(
                    children: List.generate(item.options.length, (optIndex) {
                      return RadioListTile<int>(
                        title: Text(
                          item.options[optIndex].label,
                          style: const TextStyle(fontSize: 12),
                        ),
                        value: item.options[optIndex].score,
                        dense: true,
                      );
                    }),
                  ),
                ),
              ],
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
      case SeverityLevel.mild:
        return AppColors.severityMild;
      case SeverityLevel.moderate:
        return AppColors.severityModerate;
      case SeverityLevel.severe:
        return AppColors.severitySevere;
    }
  }
}
