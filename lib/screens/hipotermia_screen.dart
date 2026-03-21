import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/tool_screen_base.dart';

class HipotermiaScreen extends StatefulWidget {
  const HipotermiaScreen({super.key});

  @override
  State<HipotermiaScreen> createState() => _HipotermiaScreenState();
}

class _HipotermiaScreenState extends State<HipotermiaScreen> {
  double _temperature = 36.5;

  // ── Classification helpers ──────────────────────────────────────────

  String get _gradeName {
    if (_temperature >= 35) return 'NORMAL';
    if (_temperature >= 32) return 'LEVE';
    if (_temperature >= 28) return 'MODERADA';
    return 'GRAVE';
  }

  Color get _gradeColor {
    if (_temperature >= 35) return AppColors.severityMild;
    if (_temperature >= 32) return AppColors.severityModerate;
    return AppColors.severitySevere;
  }

  String get _gradeRange {
    if (_temperature >= 35) return '≥ 35 °C';
    if (_temperature >= 32) return '32 – 35 °C';
    if (_temperature >= 28) return '28 – 32 °C';
    return '< 28 °C';
  }

  List<String> get _currentSymptoms {
    if (_temperature >= 35) {
      return ['Temperatura corporal normal', 'Sin signos de hipotermia'];
    }
    if (_temperature >= 32) {
      return [
        'Temblor intenso',
        'Vasoconstricción',
        'Taquicardia, taquipnea',
        'Confusión leve',
      ];
    }
    if (_temperature >= 28) {
      return [
        'Desaparece el temblor',
        'Rigidez muscular',
        'Bradicardia, hipotensión',
        'Disminución nivel consciencia',
        'Pupilas dilatadas',
      ];
    }
    return [
      'Coma',
      'Arritmias graves (FV)',
      'Rigidez extrema',
      'Apariencia de muerte',
    ];
  }

  List<String> get _currentTreatment {
    if (_temperature >= 35) {
      return [
        'No requiere tratamiento específico',
        'Mantener ambiente cálido',
      ];
    }
    if (_temperature >= 32) {
      return [
        'Retirar ropa mojada',
        'Recalentamiento pasivo (mantas, ambiente cálido)',
        'Bebidas calientes (si consciente)',
        'Monitorizar',
      ];
    }
    if (_temperature >= 28) {
      return [
        'Recalentamiento activo externo (mantas térmicas)',
        'Manipulación cuidadosa (riesgo arritmias)',
        'Monitorización cardiaca',
        'Traslado hospitalario',
      ];
    }
    return [
      'NO declarar fallecido hasta recalentado',
      '"Nadie está muerto hasta que está caliente y muerto"',
      'RCP si no hay signos de vida',
      'Recalentamiento activo interno (hospitalario)',
      'Traslado urgente a hospital con CEC/ECMO',
    ];
  }

  void _reset() => setState(() => _temperature = 36.5);

  // ── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ToolScreenBase(
      title: 'Hipotermia',
      onReset: _reset,
      resultWidget: ResultBanner(
        value: '${_temperature.toStringAsFixed(1)} °C',
        label: _gradeName,
        subtitle: _gradeRange,
        color: _gradeColor,
      ),
      toolBody: _buildToolBody(),
      infoBody: _buildInfoBody(),
    );
  }

  // ── Tool tab ────────────────────────────────────────────────────────

  Widget _buildToolBody() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Temperature slider
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Temperatura corporal',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('25 °C', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Slider(
                        value: _temperature,
                        min: 25,
                        max: 37,
                        divisions: 24, // (37-25) / 0.5
                        activeColor: _gradeColor,
                        label: '${_temperature.toStringAsFixed(1)} °C',
                        onChanged: (v) => setState(() => _temperature = v),
                      ),
                    ),
                    const Text('37 °C', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Current grade detail card
        _buildGradeCard(
          'Hipotermia $_gradeName ($_gradeRange)',
          _gradeColor,
          _currentSymptoms,
          _currentTreatment,
        ),
      ],
    );
  }

  // ── Info tab ────────────────────────────────────────────────────────

  Widget _buildInfoBody() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // General info
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Hipotermia',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'La hipotermia se define como una temperatura corporal central '
                  'inferior a 35 °C. Puede ser accidental (exposición ambiental) o '
                  'secundaria a otras patologías. La gravedad se clasifica en tres '
                  'grados según la temperatura corporal.',
                  style: TextStyle(fontSize: 13),
                ),
                SizedBox(height: 8),
                Text(
                  'Principio clave: "Nadie está muerto hasta que está caliente y muerto". '
                  'No se debe declarar el fallecimiento de un paciente hipotérmico hasta '
                  'que haya sido recalentado.',
                  style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // All three grades
        _buildGradeCard('Leve (32 – 35 °C)', AppColors.severityModerate, [
          'Temblor intenso',
          'Vasoconstricción',
          'Taquicardia, taquipnea',
          'Confusión leve',
        ], [
          'Retirar ropa mojada',
          'Recalentamiento pasivo (mantas, ambiente cálido)',
          'Bebidas calientes (si consciente)',
          'Monitorizar',
        ]),
        _buildGradeCard('Moderada (28 – 32 °C)', AppColors.severitySevere, [
          'Desaparece el temblor',
          'Rigidez muscular',
          'Bradicardia, hipotensión',
          'Disminución nivel consciencia',
          'Pupilas dilatadas',
        ], [
          'Recalentamiento activo externo (mantas térmicas)',
          'Manipulación cuidadosa (riesgo arritmias)',
          'Monitorización cardiaca',
          'Traslado hospitalario',
        ]),
        _buildGradeCard('Grave (< 28 °C)', AppColors.severitySevere, [
          'Coma',
          'Arritmias graves (FV)',
          'Rigidez extrema',
          'Apariencia de muerte',
        ], [
          'NO declarar fallecido hasta recalentado',
          '"Nadie está muerto hasta que está caliente y muerto"',
          'RCP si no hay signos de vida',
          'Recalentamiento activo interno (hospitalario)',
          'Traslado urgente a hospital con CEC/ECMO',
        ]),
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Referencias', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
                SizedBox(height: 8),
                Text(
                  'Brown DJA, et al. Accidental hypothermia. N Engl J Med. 2012;367:1930-1938.\n\n'
                  'Paal P, et al. Accidental hypothermia: an update. Scand J Trauma Resusc Emerg Med. 2016;24:111.\n\n'
                  'ERC Guidelines 2025. Resuscitation.\n\n'
                  'PHTLS: Prehospital Trauma Life Support. 9th Edition. Jones & Bartlett, 2020.',
                  style: TextStyle(fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }

  // ── Shared card builder ─────────────────────────────────────────────

  Widget _buildGradeCard(
    String title,
    Color color,
    List<String> symptoms,
    List<String> treatment,
  ) {
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
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Sintomas:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...symptoms.map((s) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 14)),
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
                      const Text('• ', style: TextStyle(fontSize: 14)),
                      Expanded(child: Text(t, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
