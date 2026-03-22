import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/domain/entities/severity.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/theme/app_colors.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_screen_base.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/result_banner.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_info_panel.dart';
import '../domain/madrid_direct_calculator.dart';
import '../domain/madrid_direct_data.dart';

class MadridDirectScreen extends StatefulWidget {
  const MadridDirectScreen({super.key});

  @override
  State<MadridDirectScreen> createState() => _MadridDirectScreenState();
}

class _MadridDirectScreenState extends State<MadridDirectScreen> {
  static const _calculator = MadridDirectCalculator();

  // Clinical items (+1 each)
  bool _armNoGravity = false;
  bool _legNoGravity = false;
  bool _gazeDeviation = false;
  bool _noObeyOrders = false;
  bool _noRecognizeDeficit = false;

  // Modifiers
  int _tas = 140;
  int _age = 65;

  MadridDirectResult get _result => _calculator.calculate(
        armNoGravity: _armNoGravity,
        legNoGravity: _legNoGravity,
        gazeDeviation: _gazeDeviation,
        noObeyOrders: _noObeyOrders,
        noRecognizeDeficit: _noRecognizeDeficit,
        tas: _tas,
        age: _age,
      );

  void _reset() => setState(() {
        _armNoGravity = false;
        _legNoGravity = false;
        _gazeDeviation = false;
        _noObeyOrders = false;
        _noRecognizeDeficit = false;
        _tas = 140;
        _age = 65;
      });

  @override
  Widget build(BuildContext context) {
    final r = _result;
    return ToolScreenBase(
      title: 'Madrid-DIRECT',
      onReset: _reset,
      resultWidget: ResultBanner(
        value: '${r.score}',
        label: r.requiresThrombectomy
            ? 'TRASLADO DIRECTO A TROMBECTOMIA'
            : 'TRASLADO A UI MAS CERCANA',
        subtitle: r.requiresThrombectomy
            ? '>= 2 puntos: sospecha de oclusion de gran vaso'
            : '< 2 puntos: trasladar al hospital con UI mas cercano',
        color: r.severity.level.color,
      ),
      toolBody: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 4),
            child: Text('Items clinicos (+1 punto cada uno)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          _buildClinicalItem(
            'Brazo - No vence gravedad',
            Icons.front_hand,
            'Balance muscular 0-2 (NIHSS 3-4 en este item)',
            _armNoGravity,
            (v) => setState(() => _armNoGravity = v),
          ),
          _buildClinicalItem(
            'Pierna - No vence gravedad',
            Icons.directions_walk,
            'Balance muscular 0-2 (NIHSS 3-4 en este item)',
            _legNoGravity,
            (v) => setState(() => _legNoGravity = v),
          ),
          _buildClinicalItem(
            'Desviacion de la mirada',
            Icons.visibility,
            'Parcial o forzada (NIHSS 1-2 en este item)',
            _gazeDeviation,
            (v) => setState(() => _gazeDeviation = v),
          ),
          _buildClinicalItem(
            'No obedece ordenes',
            Icons.record_voice_over,
            'No obedece la mitad o mas de ordenes sencillas (NIHSS 1-2)',
            _noObeyOrders,
            (v) => setState(() {
              _noObeyOrders = v;
              if (v) _noRecognizeDeficit = false;
            }),
          ),
          _buildClinicalItem(
            'No reconoce deficit',
            Icons.blur_on,
            'Preguntar: "De quien es este brazo?" y '
                '"Puede mover bien los brazos?"',
            _noRecognizeDeficit,
            (v) => setState(() {
              _noRecognizeDeficit = v;
              if (v) _noObeyOrders = false;
            }),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 4),
            child: Text('Modificadores (restan puntos)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          // TAS modifier
          Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.speed, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text('TAS: $_tas mmHg',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      if (_tas >= 180)
                        Text(
                          '-${((_tas - 180) ~/ 10) + 1} pts',
                          style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  Slider(
                    value: _tas.toDouble(),
                    min: 80,
                    max: 250,
                    divisions: 34,
                    activeColor:
                        _tas >= 180 ? Colors.orange : AppColors.primary,
                    onChanged: (v) => setState(() => _tas = v.round()),
                  ),
                  const Text('Restar 1 punto por cada 10 mmHg > 180',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ),
          // Age modifier
          Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cake, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text('Edad: $_age anos',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      if (_age >= 85)
                        Text(
                          '-${_age - 84} pts',
                          style: const TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  Slider(
                    value: _age.toDouble(),
                    min: 18,
                    max: 100,
                    divisions: 82,
                    activeColor: _age >= 85 ? Colors.purple : AppColors.primary,
                    onChanged: (v) => setState(() => _age = v.round()),
                  ),
                  const Text('Restar 1 punto por cada ano a partir de 85',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ),
          // Age caveat
          if (!r.requiresThrombectomy && _age >= 85)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Card(
                color: Color(0xFFFFF8E1),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Si la puntuacion es < 2 solo por la edad y el paciente '
                    'tiene excelente situacion basal, valorar con neurologo '
                    'la posibilidad de traslado directo a TM.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      infoBody: const ToolInfoPanel(
        sections: MadridDirectData.infoSections,
        references: MadridDirectData.references,
      ),
    );
  }

  Widget _buildClinicalItem(
    String title,
    IconData icon,
    String description,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: SwitchListTile(
        secondary:
            Icon(icon, color: value ? AppColors.severitySevere : Colors.grey),
        title: Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(description, style: const TextStyle(fontSize: 11)),
        value: value,
        activeThumbColor: AppColors.severitySevere,
        onChanged: (v) => onChanged(v),
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
