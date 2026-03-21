import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/tool_screen_base.dart';

class _GlasgowItem {
  final String label;
  final int score;
  const _GlasgowItem(this.label, this.score);
}

const _eyeResponses = [
  _GlasgowItem('Espontánea', 4),
  _GlasgowItem('A la voz', 3),
  _GlasgowItem('Al dolor', 2),
  _GlasgowItem('Ninguna', 1),
];

const _verbalResponses = [
  _GlasgowItem('Orientado', 5),
  _GlasgowItem('Confuso', 4),
  _GlasgowItem('Palabras inapropiadas', 3),
  _GlasgowItem('Sonidos incomprensibles', 2),
  _GlasgowItem('Ninguna', 1),
];

const _motorResponses = [
  _GlasgowItem('Obedece órdenes', 6),
  _GlasgowItem('Localiza dolor', 5),
  _GlasgowItem('Retirada al dolor', 4),
  _GlasgowItem('Flexión anormal', 3),
  _GlasgowItem('Extensión', 2),
  _GlasgowItem('Ninguna', 1),
];

class GlasgowScreen extends StatefulWidget {
  const GlasgowScreen({super.key});

  @override
  State<GlasgowScreen> createState() => _GlasgowScreenState();
}

class _GlasgowScreenState extends State<GlasgowScreen> {
  int _eyeScore = 4;
  int _verbalScore = 5;
  int _motorScore = 6;

  int get _total => _eyeScore + _verbalScore + _motorScore;

  Color get _severityColor {
    if (_total >= 13) return AppColors.severityMild;
    if (_total >= 9) return AppColors.severityModerate;
    return AppColors.severitySevere;
  }

  String get _severityLabel {
    if (_total >= 13) return 'Leve';
    if (_total >= 9) return 'Moderado';
    return 'Grave';
  }

  void _reset() => setState(() {
    _eyeScore = 4;
    _verbalScore = 5;
    _motorScore = 6;
  });

  @override
  Widget build(BuildContext context) {
    return ToolScreenBase(
      title: 'Escala de Glasgow',
      onReset: _reset,
      resultWidget: ResultBanner(
        value: '$_total',
        label: _severityLabel,
        subtitle: 'O: $_eyeScore  V: $_verbalScore  M: $_motorScore',
        color: _severityColor,
      ),
      toolBody: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildSection('Ocular (O)', Icons.remove_red_eye, _eyeResponses, _eyeScore,
              (v) => setState(() => _eyeScore = v)),
          const SizedBox(height: 8),
          _buildSection('Verbal (V)', Icons.record_voice_over, _verbalResponses, _verbalScore,
              (v) => setState(() => _verbalScore = v)),
          const SizedBox(height: 8),
          _buildSection('Motor (M)', Icons.front_hand, _motorResponses, _motorScore,
              (v) => setState(() => _motorScore = v)),
        ],
      ),
      infoBody: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          _infoCard('¿Qué es?',
              'La Escala de Coma de Glasgow (GCS) es una escala neurológica que valora el nivel de consciencia '
              'de un paciente. Se utiliza en la valoración inicial y seguimiento de pacientes con traumatismo '
              'craneoencefálico y otras emergencias neurológicas.'),
          _infoCard('Interpretación',
              '15: Normal\n'
              '13-14: Leve (paciente alerta, puede presentar confusión)\n'
              '9-12: Moderado (respuesta al dolor, desorientado)\n'
              '3-8: Grave (coma, considerar IOT para protección de vía aérea)\n\n'
              'GCS de 8 o menor: Considerar intubación orotraqueal'),
          _infoCard('Limitaciones',
              'No valorable en pacientes sedados o relajados.\n'
              'La respuesta verbal no es evaluable en pacientes intubados.\n'
              'Edema facial o periorbitario puede impedir valorar apertura ocular.\n'
              'Lesiones medulares pueden alterar la respuesta motora.'),
          _infoCard('Cuándo aplicarla',
              'TCE (Traumatismo Craneoencefálico)\n'
              'Alteración del nivel de consciencia\n'
              'Valoración neurológica inicial\n'
              'Seguimiento evolutivo del paciente crítico'),
          _infoCard('Referencias',
              'Teasdale G, Jennett B. Assessment of coma and impaired consciousness: a practical scale. Lancet. 1974;2(7872):81-84.\n\n'
              'Teasdale G, et al. The Glasgow Coma Scale at 40 years: standing the test of time. Lancet Neurol. 2014;13(8):844-854.\n\n'
              'ERC Guidelines 2025. Resuscitation.\n\n'
              'ATLS: Advanced Trauma Life Support. 10th Edition. ACS, 2018.'),
        ],
      )),
    );
  }

  Widget _buildSection(
    String title, IconData icon, List<_GlasgowItem> items, int selectedScore, ValueChanged<int> onChanged,
  ) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ...items.map((item) {
            final isSelected = item.score == selectedScore;
            return ListTile(
              dense: true,
              selected: isSelected,
              selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
              title: Text(item.label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : null)),
              trailing: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text('${item.score}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey))),
              ),
              onTap: () => onChanged(item.score),
            );
          }),
        ],
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
