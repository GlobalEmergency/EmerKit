import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emerkit/shared/domain/entities/severity.dart';
import 'package:emerkit/shared/presentation/theme/app_colors.dart';
import 'package:emerkit/shared/presentation/widgets/result_banner.dart';
import 'package:emerkit/shared/presentation/widgets/section_header.dart';
import 'package:emerkit/shared/presentation/widgets/tool_info_panel.dart';
import 'package:emerkit/shared/presentation/widgets/tool_screen_base.dart';
import '../domain/wallace_calculator.dart';
import '../domain/wallace_data.dart';

class WallaceScreen extends StatefulWidget {
  const WallaceScreen({super.key});

  @override
  State<WallaceScreen> createState() => _WallaceScreenState();
}

class _WallaceScreenState extends State<WallaceScreen> {
  static const _calculator = WallaceCalculator();

  int _selectedAge = 0;
  late List<bool> _burnedZones;
  final _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _burnedZones = List.filled(WallaceData.zoneNames.length, false);
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  double? get _weightKg {
    final text = _weightController.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  WallaceResult get _result => _calculator.calculate(
        burnedZones: _burnedZones,
        ageGroupIndex: _selectedAge,
        weightKg: _weightKg,
      );

  void _reset() {
    setState(() {
      _selectedAge = 0;
      for (int i = 0; i < _burnedZones.length; i++) {
        _burnedZones[i] = false;
      }
      _weightController.clear();
    });
  }

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

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final color = result.totalScq == 0
        ? Colors.grey
        : _colorForSeverity(result.severity.level);

    String subtitle = 'SCQ - Superficie Corporal Quemada';
    if (result.hasSpecialZone) {
      subtitle += '\n\u26a0 Zona especial afectada';
    }

    return ToolScreenBase(
      title: 'Regla de Wallace',
      onReset: _reset,
      resultWidget: ResultBanner(
        value: '${result.totalScq.toStringAsFixed(0)}%',
        label: result.severity.label,
        subtitle: subtitle,
        color: color,
        severityLevel: result.severity.level,
      ),
      toolBody: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // Age selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(WallaceData.ageGroups.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(WallaceData.ageGroups[i]),
                      selected: _selectedAge == i,
                      selectedColor: AppColors.valoracion,
                      labelStyle:
                          Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: _selectedAge == i ? Colors.white : null,
                                fontWeight:
                                    _selectedAge == i ? FontWeight.bold : null,
                              ),
                      onSelected: (_) => setState(() => _selectedAge = i),
                    ),
                  );
                }),
              ),
            ),
          ),
          // Body zones
          ...List.generate(WallaceData.zoneNames.length, (index) {
            final name = WallaceData.zoneNames[index];
            final pct = WallaceData.zonePercentages[index][_selectedAge];
            final burned = _burnedZones[index];
            final isSpecial = WallaceData.specialZoneIndices.contains(index);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              color: burned
                  ? const Color(0xFFE57373).withValues(alpha: 0.15)
                  : null,
              child: CheckboxListTile(
                dense: true,
                activeColor: AppColors.severitySevere,
                value: burned,
                onChanged: (v) =>
                    setState(() => _burnedZones[index] = v ?? false),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    if (isSpecial)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: AppColors.severityModerate,
                        ),
                      ),
                    Text(
                      '${pct.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: burned ? AppColors.severitySevere : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          // Weight input
          const SectionHeader(
            title: 'Reposicion hidrica',
            color: AppColors.valoracion,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Peso del paciente',
                suffixText: 'kg',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          // Fluid resuscitation panel
          if (result.parkland24h != null) _buildFluidPanel(result),
          if (result.totalScq > 0 && result.parkland24h == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                result.totalScq < (_selectedAge > 0 ? 10 : 20)
                    ? 'SCQ inferior al umbral de reposicion hidrica '
                        '(${_selectedAge > 0 ? "10" : "20"}%)'
                    : 'Introduce el peso para calcular la reposicion hidrica',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
        ],
      ),
      infoBody: const ToolInfoPanel(
        sections: WallaceData.infoSections,
        references: WallaceData.references,
      ),
    );
  }

  Widget _buildFluidPanel(WallaceResult result) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: AppColors.valoracion.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fluidRow(
              'Parkland (24h total)',
              '${result.parkland24h!.toStringAsFixed(0)} mL',
            ),
            _fluidRow(
              'Primeras 8h',
              '${result.parklandFirst8hRate!.toStringAsFixed(0)} mL/h',
            ),
            _fluidRow(
              'Siguientes 16h',
              '${result.parklandNext16hRate!.toStringAsFixed(0)} mL/h',
            ),
            const Divider(height: 16),
            _fluidRow(
              'Regla del 10 (USAISR)',
              '${result.ruleOf10Rate!.toStringAsFixed(0)} mL/h',
            ),
            const Divider(height: 16),
            _fluidRow(
              'Diuresis objetivo',
              '${result.urineTargetMin!.toStringAsFixed(0)}-'
                  '${result.urineTargetMax!.toStringAsFixed(0)} mL/h',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.severityModerate.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: AppColors.severityModerate),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Ritmos iniciales. Titular segun diuresis. '
                      'Fluido: Ringer Lactato.',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fluidRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
