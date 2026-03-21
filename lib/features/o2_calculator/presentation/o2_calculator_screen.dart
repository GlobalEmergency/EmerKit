import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/domain/entities/severity.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/theme/app_colors.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_screen_base.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/result_banner.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_info_panel.dart';
import '../domain/o2_calculator.dart';
import '../domain/o2_calculator_data.dart';

class O2CalculatorScreen extends StatefulWidget {
  const O2CalculatorScreen({super.key});

  @override
  State<O2CalculatorScreen> createState() => _O2CalculatorScreenState();
}

class _O2CalculatorScreenState extends State<O2CalculatorScreen> {
  int _selectedBottle = 3; // 5L por defecto
  double _pressure = 200; // bar
  double _flowRate = 10; // L/min

  O2Result get _result => O2Calculator.calculate(
        bottleLiters: O2CalculatorData.bottles[_selectedBottle].liters,
        pressure: _pressure,
        flowRate: _flowRate,
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

  void _reset() => setState(() {
        _selectedBottle = 3;
        _pressure = 200;
        _flowRate = 10;
      });

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final color = _colorForSeverity(result.severity.level);

    return ToolScreenBase(
      title: 'Calculadora O\u2082',
      onReset: _reset,
      resultWidget: ResultBanner(
        value: result.formatted,
        label: 'Autonomia estimada',
        subtitle: result.autonomyMinutes > 0
            ? '${O2CalculatorData.bottles[_selectedBottle].label} \u00b7 ${_pressure.round()} bar \u00b7 ${_flowRate.round()} L/min'
            : null,
        color: color,
      ),
      toolBody: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Tamano de botella',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(O2CalculatorData.bottles.length, (i) {
              final isSelected = _selectedBottle == i;
              return ChoiceChip(
                label: Text(O2CalculatorData.bottles[i].label),
                selected: isSelected,
                selectedColor: AppColors.oxigenoterapia,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
                onSelected: (_) => setState(() => _selectedBottle = i),
              );
            }),
          ),
          const SizedBox(height: 20),
          _buildSlider(
            'Presion del manometro',
            '${_pressure.round()} bar',
            _pressure,
            20,
            300,
            10,
            (v) => setState(() => _pressure = v),
          ),
          const SizedBox(height: 16),
          _buildSlider(
            'Caudal (caudalimetro)',
            '${_flowRate.round()} L/min',
            _flowRate,
            0,
            15,
            1,
            (v) => setState(() => _flowRate = v),
          ),
        ],
      ),
      infoBody: ToolInfoPanel(
        sections: O2CalculatorData.infoSections,
        references: O2CalculatorData.references,
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
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(valueText,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.oxigenoterapia)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) / step).round(),
          activeColor: AppColors.oxigenoterapia,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
