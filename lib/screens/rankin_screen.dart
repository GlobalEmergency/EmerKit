import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/tool_screen_base.dart';

class _RankinLevel {
  final int score;
  final String title;
  final String description;
  final Color color;
  const _RankinLevel(this.score, this.title, this.description, this.color);
}

const _levels = [
  _RankinLevel(0, 'Asintomático', 'Sin síntomas', AppColors.severityMild),
  _RankinLevel(1, 'Sin incapacidad importante', 'Capaz de realizar sus actividades habituales a pesar de algún síntoma', AppColors.severityMild),
  _RankinLevel(2, 'Incapacidad leve', 'Incapaz de realizar alguna de sus actividades previas, pero capaz de valerse por sí mismo sin ayuda', AppColors.severityMild),
  _RankinLevel(3, 'Incapacidad moderada', 'Necesita alguna ayuda pero es capaz de caminar sin asistencia', AppColors.severityModerate),
  _RankinLevel(4, 'Incapacidad moderadamente grave', 'Incapaz de caminar sin ayuda. Incapaz de atender sus necesidades corporales sin ayuda', AppColors.severityModerate),
  _RankinLevel(5, 'Incapacidad grave', 'Totalmente dependiente. Necesita asistencia constante día y noche', AppColors.severitySevere),
  _RankinLevel(6, 'Muerte', '', AppColors.triageBlack),
];

class RankinScreen extends StatefulWidget {
  const RankinScreen({super.key});

  @override
  State<RankinScreen> createState() => _RankinScreenState();
}

class _RankinScreenState extends State<RankinScreen> {
  int? _selected;

  String get _independenceLabel {
    if (_selected == null) return '';
    if (_selected! <= 2) return 'Independiente para ABVD';
    if (_selected! <= 4) return 'Semidependiente para ABVD';
    return 'Dependiente para ABVD';
  }

  Color get _selectedColor {
    if (_selected == null) return Colors.grey;
    return _levels[_selected!].color;
  }

  void _reset() => setState(() => _selected = null);

  @override
  Widget build(BuildContext context) {
    return ToolScreenBase(
      title: 'Escala Rankin Modificada',
      onReset: _reset,
      emptyResultText: 'Selecciona el nivel de dependencia',
      resultWidget: _selected != null
          ? ResultBanner(
              value: '$_selected',
              label: _levels[_selected!].title,
              subtitle: _independenceLabel,
              color: _selectedColor,
            )
          : null,
      toolBody: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ..._levels.map((level) {
            final isSelected = _selected == level.score;
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              color: isSelected ? level.color.withValues(alpha: 0.15) : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isSelected ? BorderSide(color: level.color, width: 2) : BorderSide.none,
              ),
              child: ListTile(
                onTap: () => setState(() => _selected = level.score),
                leading: CircleAvatar(
                  backgroundColor: level.color,
                  child: Text('${level.score}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                title: Text(level.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: level.description.isNotEmpty ? Text(level.description, style: const TextStyle(fontSize: 12)) : null,
              ),
            );
          }),
        ],
      ),
      infoBody: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoCard('¿Qué es?',
                'La Escala de Rankin Modificada (mRS) es una escala de valoración funcional '
                'que mide el grado de discapacidad o dependencia en las actividades de la vida '
                'diaria tras un ictus u otra patología neurológica. Es la escala más utilizada '
                'como variable de resultado en ensayos clínicos de ictus.'),
            _infoCard('Interpretación',
                '0: Asintomático, sin limitaciones\n'
                '1: Sin incapacidad significativa, capaz de realizar actividades habituales\n'
                '2: Incapacidad leve, independiente pero con algunas limitaciones\n'
                '3: Incapacidad moderada, necesita algo de ayuda pero camina solo\n'
                '4: Incapacidad moderada-grave, no puede caminar ni atender necesidades solo\n'
                '5: Incapacidad grave, totalmente dependiente\n'
                '6: Muerte\n\n'
                'Se considera buen resultado funcional una puntuación de 0-2 '
                '(independiente para actividades básicas de la vida diaria).'),
            _infoCard('Cuándo aplicarla',
                'Evaluación funcional post-ictus (al alta y en seguimiento).\n'
                'Variable de resultado en ensayos clínicos de ictus.\n'
                'Valoración de la discapacidad en patología neurológica.\n'
                'Toma de decisiones sobre tratamiento y destino al alta.'),
            _infoCard('Limitaciones',
                'Subjetividad en la diferenciación entre niveles adyacentes.\n'
                'No capta cambios sutiles dentro de un mismo nivel.\n'
                'No evalúa dominios cognitivos ni emocionales específicamente.\n'
                'Variabilidad interobservador, especialmente en niveles intermedios.'),
            _infoCard('Referencias',
                'van Swieten JC, et al. Interobserver agreement for the assessment of '
                'handicap in stroke patients. Stroke. 1988;19(5):604-607.\n\n'
                'Banks JL, Marotta CA. Outcomes validity and reliability of the modified '
                'Rankin scale. Stroke. 2007;38(3):1091-1096.'),
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
