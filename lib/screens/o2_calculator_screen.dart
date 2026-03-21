import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/tool_screen_base.dart';

class _BottleSize {
  final String label;
  final double liters;
  const _BottleSize(this.label, this.liters);
}

const _bottles = [
  _BottleSize('1 L', 1),
  _BottleSize('2 L', 2),
  _BottleSize('3 L', 3),
  _BottleSize('5 L', 5),
  _BottleSize('7 L', 7),
  _BottleSize('10 L', 10),
];

class O2CalculatorScreen extends StatefulWidget {
  const O2CalculatorScreen({super.key});

  @override
  State<O2CalculatorScreen> createState() => _O2CalculatorScreenState();
}

class _O2CalculatorScreenState extends State<O2CalculatorScreen> {
  int _selectedBottle = 3; // 5L por defecto
  double _pressure = 200; // bar
  double _flowRate = 10; // L/min

  static const double _securityReserve = 20; // 20 bar de reserva de seguridad

  double get _usablePressure =>
      (_pressure - _securityReserve).clamp(0, double.infinity);

  double get _autonomyMinutes {
    final bottle = _bottles[_selectedBottle];
    if (_flowRate == 0 || _usablePressure <= 0) return 0;
    return (bottle.liters * _usablePressure) / _flowRate;
  }

  String get _autonomyText {
    if (_autonomyMinutes.isInfinite) return '--:--';
    final totalMin = _autonomyMinutes.round();
    final hours = totalMin ~/ 60;
    final minutes = totalMin % 60;
    return '${hours}h ${minutes.toString().padLeft(2, '0')}min';
  }

  Color get _autonomyColor {
    if (_autonomyMinutes.isInfinite) return Colors.grey;
    if (_autonomyMinutes < 10) return AppColors.severitySevere;
    if (_autonomyMinutes < 30) return AppColors.severityModerate;
    return AppColors.severityMild;
  }

  void _reset() => setState(() {
        _selectedBottle = 3;
        _pressure = 200;
        _flowRate = 10;
      });

  @override
  Widget build(BuildContext context) {
    return ToolScreenBase(
      title: 'Calculadora O\u2082',
      onReset: _reset,
      resultWidget: ResultBanner(
        value: _autonomyText,
        label: 'Autonomia estimada',
        subtitle: _autonomyMinutes > 0
            ? '${_bottles[_selectedBottle].label} \u00b7 ${_pressure.round()} bar \u00b7 ${_flowRate.round()} L/min'
            : null,
        color: _autonomyColor,
      ),
      toolBody: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Bottle selector
          const Text('Tamano de botella',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(_bottles.length, (i) {
              final isSelected = _selectedBottle == i;
              return ChoiceChip(
                label: Text(_bottles[i].label),
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

          // Pressure slider
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

          // Flow rate slider
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
      infoBody: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoCard(
            'Formula',
            'Autonomia = (Volumen botella x Presion util) / Caudal\n\n'
                'Ejemplo con los valores actuales:\n'
                'Autonomia = (${_bottles[_selectedBottle].liters} L x ${_usablePressure.round()} bar) / ${_flowRate.round()} L/min '
                '= ${_autonomyMinutes.round()} min',
          ),
          _infoCard(
            'Reserva de seguridad (20 bar)',
            'Siempre se descuentan 20 bar de la presion del manometro como '
                'reserva de seguridad. Esto garantiza un margen antes de que la '
                'botella se agote por completo.\n\n'
                'Presion util = Presion manometro - 20 bar\n'
                'En tu caso: ${_pressure.round()} - 20 = ${_usablePressure.round()} bar utiles',
          ),
          _infoCard(
            'Tamanos de botella habituales',
            '1 L: Botella portatil pequena, emergencias rapidas\n'
                '2 L: Portatil, traslados cortos\n'
                '3 L: Portatil, uso frecuente en ambulancias\n'
                '5 L: Estandar en SVB y SVA\n'
                '7 L: Uso hospitalario y traslados largos\n'
                '10 L: Gran capacidad, hospitales y reserva',
          ),
          _infoCard(
            'Consejos para emergencias',
            'Verifica siempre la presion antes de cada servicio.\n'
                'Lleva una botella de repuesto si el traslado es largo.\n'
                'Ajusta el caudal al minimo eficaz segun SpO2.\n'
                'Recuerda: con menos de 50 bar la botella esta practicamente vacia.\n'
                'Autonomia < 10 min: prepara cambio de botella inmediato.',
          ),
          _infoCard('Referencias',
              'BTS Guideline for Oxygen Use in Healthcare and Emergency Settings. Thorax. 2017;72:ii1-ii90.\n\n'
              'PHTLS: Prehospital Trauma Life Support. 9th Edition. Jones & Bartlett, 2020.\n\n'
              'O\'Driscoll BR, et al. BTS guideline for oxygen use in adults in healthcare and emergency settings. Thorax. 2017.'),
        ],
      )),
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

  Widget _infoCard(String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
