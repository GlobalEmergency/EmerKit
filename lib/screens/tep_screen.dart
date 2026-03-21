import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/tool_screen_base.dart';

class TepScreen extends StatefulWidget {
  const TepScreen({super.key});

  @override
  State<TepScreen> createState() => _TepScreenState();
}

class _TepScreenState extends State<TepScreen> {
  bool? _apariencia; // null=no seleccionado, true=normal, false=anormal
  bool? _respiracion;
  bool? _circulacion;

  int get _abnormalCount =>
      [_apariencia, _respiracion, _circulacion].where((v) => v == false).length;

  String? get _resultado {
    if (_apariencia == null || _respiracion == null || _circulacion == null) return null;

    if (_abnormalCount == 0) return 'ESTABLE';
    if (_abnormalCount == 3) return 'PARADA CARDIORRESPIRATORIA';

    // Un lado alterado
    if (_abnormalCount == 1) {
      if (_apariencia == false) return 'DISFUNCIÓN DEL SNC';
      if (_respiracion == false) return 'DIFICULTAD RESPIRATORIA';
      if (_circulacion == false) return 'SHOCK COMPENSADO';
    }

    // Dos lados alterados
    if (_apariencia == false && _respiracion == false) return 'FALLO RESPIRATORIO';
    if (_apariencia == false && _circulacion == false) return 'SHOCK DESCOMPENSADO';
    if (_respiracion == false && _circulacion == false) return 'FALLO CARDIORRESPIRATORIO';

    return null;
  }

  Color get _resultColor {
    if (_resultado == null) return Colors.grey;
    if (_resultado == 'ESTABLE') return AppColors.severityMild;
    if (_abnormalCount == 3) return AppColors.severitySevere;
    if (_abnormalCount == 2) return AppColors.severitySevere;
    return AppColors.severityModerate;
  }

  void _reset() {
    setState(() {
      _apariencia = null;
      _respiracion = null;
      _circulacion = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ToolScreenBase(
      title: 'TEP',
      onReset: _reset,
      emptyResultText: 'Evalúa los 3 lados del triángulo',
      resultWidget: _resultado != null
          ? ResultBanner(
              value: _resultado!,
              label: _abnormalCount == 0
                  ? 'Sin alteraciones'
                  : '$_abnormalCount lado${_abnormalCount > 1 ? 's' : ''} alterado${_abnormalCount > 1 ? 's' : ''}',
              color: _resultColor,
            )
          : null,
      toolBody: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTriangleSide(
            'Apariencia',
            Icons.child_care,
            'Tono, interacción, consolabilidad, mirada, habla/llanto',
            _apariencia,
            (v) => setState(() => _apariencia = v),
          ),
          const SizedBox(height: 12),
          _buildTriangleSide(
            'Trabajo respiratorio',
            Icons.air,
            'Sonidos anormales, posición anormal, retracciones, aleteo nasal',
            _respiracion,
            (v) => setState(() => _respiracion = v),
          ),
          const SizedBox(height: 12),
          _buildTriangleSide(
            'Circulación cutánea',
            Icons.favorite,
            'Palidez, cianosis, cutis reticular',
            _circulacion,
            (v) => setState(() => _circulacion = v),
          ),
        ],
      ),
      infoBody: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoCard('¿Qué es?',
                'El Triángulo de Evaluación Pediátrica (TEP) es una herramienta de valoración '
                'inicial rápida del paciente pediátrico. Permite identificar en segundos el tipo '
                'y gravedad de la situación clínica mediante la observación visual y auditiva, '
                'sin necesidad de tocar al paciente.'),
            _infoCard('Lados del triángulo',
                'Apariencia: Valora la función del SNC. Se evalúa tono muscular, interactividad, '
                'consolabilidad, mirada y habla/llanto. Es el indicador más importante de gravedad.\n\n'
                'Trabajo respiratorio: Valora la función respiratoria. Se buscan sonidos anormales '
                '(estridor, quejido, sibilancias), posición anormal (trípode, olfateo), retracciones '
                'y aleteo nasal.\n\n'
                'Circulación cutánea: Valora la función circulatoria. Se observa palidez, cianosis '
                'o cutis reticular (moteado) como signos de mala perfusión.'),
            _infoCard('Interpretación',
                'Estable: Los 3 lados normales.\n\n'
                'Disfunción del SNC: Solo apariencia alterada.\n'
                'Dificultad respiratoria: Solo trabajo respiratorio alterado.\n'
                'Shock compensado: Solo circulación alterada.\n\n'
                'Fallo respiratorio: Apariencia + respiración alteradas.\n'
                'Shock descompensado: Apariencia + circulación alteradas.\n'
                'Fallo cardiorrespiratorio: Respiración + circulación alteradas.\n\n'
                'Parada cardiorrespiratoria: Los 3 lados alterados.'),
            _infoCard('Referencias',
                'Dieckmann RA, Brownstein D, Gausche-Hill M. The Pediatric Assessment Triangle. '
                'Pediatric Emergency Care, 2010.\n\n'
                'APLS: The Pediatric Emergency Medicine Resource. 6th Edition. Jones & Bartlett, 2020.'),
          ],
        ),
      ),
    );
  }

  Widget _buildTriangleSide(
    String title,
    IconData icon,
    String description,
    bool? value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ToggleButton(
                    label: 'Normal',
                    isSelected: value == true,
                    color: AppColors.severityMild,
                    onTap: () => onChanged(true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ToggleButton(
                    label: 'Anormal',
                    isSelected: value == false,
                    color: AppColors.severitySevere,
                    onTap: () => onChanged(false),
                  ),
                ),
              ],
            ),
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

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? color : Colors.grey.shade200,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
