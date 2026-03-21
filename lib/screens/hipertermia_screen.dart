import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/tool_screen_base.dart';

class HipertermiaScreen extends StatefulWidget {
  const HipertermiaScreen({super.key});

  @override
  State<HipertermiaScreen> createState() => _HipertermiaScreenState();
}

class _HipertermiaScreenState extends State<HipertermiaScreen> {
  double _temperature = 37.0;

  String get _classification {
    if (_temperature > 40) return 'GOLPE DE CALOR';
    if (_temperature >= 38) return 'AGOTAMIENTO POR CALOR';
    if (_temperature >= 37.5) return 'FEBRÍCULA';
    return 'NORMAL';
  }

  Color get _classificationColor {
    if (_temperature > 40) return AppColors.severitySevere;
    if (_temperature >= 38) return AppColors.severityModerate;
    if (_temperature >= 37.5) return AppColors.severityModerate;
    return AppColors.severityMild;
  }

  List<String> get _currentSymptoms {
    if (_temperature > 40) {
      return [
        'Temperatura >40°C',
        'Alteración nivel de consciencia',
        'Piel caliente y SECA (anhidrosis)',
        'Taquicardia, hipotensión',
        'Convulsiones',
        'Fracaso multiorgánico',
      ];
    }
    if (_temperature >= 38) {
      return [
        'Debilidad, fatiga intensa',
        'Sudoración profusa',
        'Taquicardia, hipotensión',
        'Náuseas, vómitos',
        'Cefalea',
        'Piel húmeda y pálida',
      ];
    }
    if (_temperature >= 37.5) {
      return [
        'Temperatura ligeramente elevada',
        'Malestar general leve',
        'Sudoración leve',
      ];
    }
    return [
      'Sin síntomas de hipertermia',
      'Temperatura corporal normal',
    ];
  }

  List<String> get _currentTreatment {
    if (_temperature > 40) {
      return [
        'EMERGENCIA VITAL',
        'Enfriamiento agresivo inmediato',
        'Inmersión en agua fría si es posible',
        'Hielo en axilas, ingles, cuello',
        'Suero IV frío',
        'Traslado urgente hospitalario',
        'NO administrar antipiréticos (no son eficaces)',
      ];
    }
    if (_temperature >= 38) {
      return [
        'Retirar del calor, lugar fresco',
        'Posición supina, piernas elevadas',
        'Retirar ropa innecesaria',
        'Enfriamiento externo (paños húmedos, ventilador)',
        'Hidratación oral/IV',
        'Monitorizar temperatura',
      ];
    }
    if (_temperature >= 37.5) {
      return [
        'Reposo en lugar fresco',
        'Hidratación oral',
        'Monitorizar evolución',
      ];
    }
    return [
      'No requiere tratamiento',
      'Mantener hidratación adecuada',
    ];
  }

  void _reset() => setState(() => _temperature = 37.0);

  @override
  Widget build(BuildContext context) {
    return ToolScreenBase(
      title: 'Hipertermia',
      onReset: _reset,
      resultWidget: ResultBanner(
        value: '${_temperature.toStringAsFixed(1)}°C',
        label: _classification,
        color: _classificationColor,
      ),
      toolBody: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Temperature slider
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.thermostat, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text('Temperatura corporal',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('${_temperature.toStringAsFixed(1)}°C',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _classificationColor,
                          )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: _temperature,
                    min: 36.0,
                    max: 43.0,
                    divisions: 14,
                    activeColor: _classificationColor,
                    label: '${_temperature.toStringAsFixed(1)}°C',
                    onChanged: (v) => setState(() => _temperature = v),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('36°C', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      Text('43°C', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Current grade card
          _buildGradeCard(
            _classification,
            _classificationColor,
            _currentSymptoms,
            _currentTreatment,
          ),
        ],
      ),
      infoBody: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGradeCard('Calambres por calor', AppColors.severityMild, [
            'Espasmos musculares dolorosos',
            'Sudoración profusa',
            'Temperatura normal o ligeramente elevada',
          ], [
            'Reposo en lugar fresco',
            'Hidratación oral (soluciones electrolíticas)',
            'Estiramiento suave de músculos afectados',
          ]),
          _buildGradeCard('Agotamiento por calor (37-40°C)', AppColors.severityModerate, [
            'Debilidad, fatiga intensa',
            'Sudoración profusa',
            'Taquicardia, hipotensión',
            'Náuseas, vómitos',
            'Cefalea',
            'Piel húmeda y pálida',
          ], [
            'Retirar del calor, lugar fresco',
            'Posición supina, piernas elevadas',
            'Retirar ropa innecesaria',
            'Enfriamiento externo (paños húmedos, ventilador)',
            'Hidratación oral/IV',
            'Monitorizar temperatura',
          ]),
          _buildGradeCard('Golpe de calor (>40°C)', AppColors.severitySevere, [
            'Temperatura >40°C',
            'Alteración nivel de consciencia',
            'Piel caliente y SECA (anhidrosis)',
            'Taquicardia, hipotensión',
            'Convulsiones',
            'Fracaso multiorgánico',
          ], [
            'EMERGENCIA VITAL',
            'Enfriamiento agresivo inmediato',
            'Inmersión en agua fría si es posible',
            'Hielo en axilas, ingles, cuello',
            'Suero IV frío',
            'Traslado urgente hospitalario',
            'NO administrar antipiréticos (no son eficaces)',
          ]),
          _infoCard('Prevención',
              'Hidratación frecuente, especialmente en ancianos y niños.\n'
              'Evitar exposición solar en horas centrales del día.\n'
              'Usar ropa ligera y transpirable.\n'
              'Nunca dejar personas o animales en vehículos cerrados.\n'
              'Aclimatación progresiva al calor en trabajadores expuestos.'),
          _infoCard('Factores de riesgo',
              'Edad extrema (niños y ancianos).\n'
              'Ejercicio intenso en ambiente caluroso.\n'
              'Fármacos (anticolinérgicos, diuréticos, betabloqueantes).\n'
              'Enfermedades crónicas (cardiovasculares, diabetes).\n'
              'Deshidratación previa.\n'
              'Obesidad.'),
          _infoCard('Referencias',
              'Bouchama A, Knochel JP. Heat Stroke. N Engl J Med. 2002;346:1978-1988.\n\n'
              'Epstein Y, Yanovich R. Heatstroke. N Engl J Med. 2019;380:2449-2459.\n\n'
              'PHTLS: Prehospital Trauma Life Support. 9th Edition. Jones & Bartlett, 2020.'),
        ],
      )),
    );
  }

  Widget _buildGradeCard(String title, Color color, List<String> symptoms, List<String> treatment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
            ),
            const SizedBox(height: 12),
            const Text('Síntomas:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...symptoms.map((s) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(s, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            const Text('Tratamiento:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...treatment.map((t) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(t, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                )),
          ],
        ),
      ),
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
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
