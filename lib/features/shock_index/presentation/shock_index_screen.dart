import 'package:flutter/material.dart';
import 'package:emerkit/shared/domain/entities/severity.dart';
import 'package:emerkit/shared/presentation/theme/app_colors.dart';
import 'package:emerkit/shared/presentation/widgets/tool_screen_base.dart';
import 'package:emerkit/shared/presentation/widgets/result_banner.dart';
import 'package:emerkit/shared/presentation/widgets/section_header.dart';
import 'package:emerkit/shared/presentation/widgets/tool_info_panel.dart';
import '../domain/shock_index_calculator.dart';
import '../domain/shock_index_data.dart';

class ShockIndexScreen extends StatefulWidget {
  const ShockIndexScreen({super.key});

  @override
  State<ShockIndexScreen> createState() => _ShockIndexScreenState();
}

class _ShockIndexScreenState extends State<ShockIndexScreen> {
  static const _calculator = ShockIndexCalculator();
  static const _color = AppColors.signosValores;

  double _heartRate = 80;
  double _systolicBP = 120;
  double _diastolicBP = 80;
  bool _isPediatric = false;
  double _age = 8;

  ShockIndexResult get _result => _calculator.calculate(
        heartRate: _heartRate.round(),
        systolicBP: _systolicBP.round(),
        diastolicBP: _diastolicBP.round(),
        isPediatric: _isPediatric,
        ageYears: _isPediatric ? _age.round() : null,
      );

  void _reset() => setState(() {
        _heartRate = 80;
        _systolicBP = 120;
        _diastolicBP = 80;
        _isPediatric = false;
        _age = 8;
      });

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
    final r = _result;
    final color = _colorForSeverity(r.severity.level);

    return ToolScreenBase(
      title: 'Indice de Shock',
      onReset: _reset,
      resultWidget: ResultBanner(
        value: r.shockIndex.toStringAsFixed(2),
        label: r.severity.label,
        subtitle: _isPediatric && r.sipaThreshold != null
            ? 'SIPA - Umbral: ${r.sipaThreshold!.toStringAsFixed(2)}'
            : 'FC ${_heartRate.round()} / TAS ${_systolicBP.round()}',
        color: color,
        severityLevel: r.severity.level,
      ),
      toolBody: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSlider(
            'Frecuencia Cardiaca',
            '${_heartRate.round()} lpm',
            _heartRate,
            30,
            220,
            1,
            (v) => setState(() => _heartRate = v),
          ),
          const SizedBox(height: 16),
          _buildSlider(
            'Presion Arterial Sistolica',
            '${_systolicBP.round()} mmHg',
            _systolicBP,
            50,
            250,
            1,
            (v) => setState(() => _systolicBP = v),
          ),
          const SizedBox(height: 16),
          _buildSlider(
            'Presion Arterial Diastolica',
            '${_diastolicBP.round()} mmHg',
            _diastolicBP,
            20,
            150,
            1,
            (v) => setState(() => _diastolicBP = v),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text('Paciente pediatrico',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.bold)),
            value: _isPediatric,
            activeTrackColor: _color,
            thumbColor: const WidgetStatePropertyAll(_color),
            onChanged: (v) => setState(() => _isPediatric = v),
          ),
          if (_isPediatric) ...[
            const SizedBox(height: 8),
            _buildSlider(
              'Edad',
              '${_age.round()} anos',
              _age,
              1,
              17,
              1,
              (v) => setState(() => _age = v),
            ),
          ],
          const SizedBox(height: 24),
          const SectionHeader(
            title: 'Resultados detallados',
            color: _color,
          ),
          const SizedBox(height: 8),
          _buildResultRow(
            'Indice de Shock (SI)',
            r.shockIndex.toStringAsFixed(2),
            r.severity,
          ),
          _buildResultRow(
            'Indice Modificado (MSI)',
            r.modifiedShockIndex.toStringAsFixed(2),
            r.msiSeverity,
          ),
          _buildResultRow(
            'Tension Arterial Media',
            '${r.tam.round()} mmHg',
            null,
          ),
          if (_isPediatric && r.sipaThreshold != null)
            _buildResultRow(
              'Umbral SIPA (${_age.round()} anos)',
              '>= ${r.sipaThreshold!.toStringAsFixed(2)}',
              null,
            ),
        ],
      ),
      infoBody: const ToolInfoPanel(
        sections: ShockIndexData.infoSections,
        references: ShockIndexData.references,
      ),
    );
  }

  Widget _buildSlider(
    String label,
    String valueText,
    double value,
    double min,
    double max,
    double step,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.bold)),
            Text(valueText,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.w600, color: _color)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) / step).round(),
          activeColor: _color,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildResultRow(String label, String value, Severity? severity) {
    final color = severity != null ? _colorForSeverity(severity.level) : _color;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              if (severity != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    severity.label,
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
