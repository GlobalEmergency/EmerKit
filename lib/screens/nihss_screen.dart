import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/tool_screen_base.dart';

class _NihssItem {
  final String name;
  final List<String> options; // index = score
  const _NihssItem(this.name, this.options);
}

const _items = [
  _NihssItem('1a. Nivel de consciencia', [
    '0 - Alerta',
    '1 - Somnoliento',
    '2 - Obnubilación',
    '3 - Coma',
  ]),
  _NihssItem('1b. Preguntas (mes y edad)', [
    '0 - Responde bien ambas',
    '1 - Responde una',
    '2 - No responde ninguna',
  ]),
  _NihssItem('1c. Órdenes (abrir/cerrar ojos, apretar mano)', [
    '0 - Realiza ambas correctamente',
    '1 - Realiza una correctamente',
    '2 - No realiza ninguna',
  ]),
  _NihssItem('2. Mirada horizontal', [
    '0 - Normal',
    '1 - Parálisis parcial de la mirada',
    '2 - Parálisis total (desviación forzada)',
  ]),
  _NihssItem('3. Campo visual', [
    '0 - Normal',
    '1 - Hemianopsia parcial',
    '2 - Hemianopsia completa',
    '3 - Hemianopsia bilateral',
  ]),
  _NihssItem('4. Parálisis facial', [
    '0 - Normal, simétrica',
    '1 - Parálisis menor (asimetría al sonreír)',
    '2 - Parálisis parcial (macizo inferior)',
    '3 - Parálisis completa uni/bilateral',
  ]),
  _NihssItem('5a. Motor brazo izquierdo', [
    '0 - Mantiene 10 segundos',
    '1 - Cae lentamente antes de 10s',
    '2 - Esfuerzo contra gravedad',
    '3 - Movimiento sin vencer gravedad',
    '4 - Ausencia de movimiento',
  ]),
  _NihssItem('5b. Motor brazo derecho', [
    '0 - Mantiene 10 segundos',
    '1 - Cae lentamente antes de 10s',
    '2 - Esfuerzo contra gravedad',
    '3 - Movimiento sin vencer gravedad',
    '4 - Ausencia de movimiento',
  ]),
  _NihssItem('6a. Motor pierna izquierda', [
    '0 - Mantiene 5 segundos',
    '1 - Cae lentamente antes de 5s',
    '2 - Esfuerzo contra gravedad',
    '3 - Movimiento sin vencer gravedad',
    '4 - Ausencia de movimiento',
  ]),
  _NihssItem('6b. Motor pierna derecha', [
    '0 - Mantiene 5 segundos',
    '1 - Cae lentamente antes de 5s',
    '2 - Esfuerzo contra gravedad',
    '3 - Movimiento sin vencer gravedad',
    '4 - Ausencia de movimiento',
  ]),
  _NihssItem('7. Ataxia de extremidades', [
    '0 - No ataxia',
    '1 - Ataxia en una extremidad',
    '2 - Ataxia en dos extremidades',
  ]),
  _NihssItem('8. Sensibilidad', [
    '0 - Normal',
    '1 - Déficit leve',
    '2 - Déficit total o bilateral',
  ]),
  _NihssItem('9. Lenguaje', [
    '0 - Normal',
    '1 - Afasia moderada (comunicación posible)',
    '2 - Afasia grave (no comunicación)',
    '3 - Mudo / comprensión global nula',
  ]),
  _NihssItem('10. Disartria', [
    '0 - Normal',
    '1 - Leve-moderada (se comprende)',
    '2 - Grave (no se comprende) / anartria',
  ]),
  _NihssItem('11. Extinción / Inatención', [
    '0 - Normal',
    '1 - Extinción en una modalidad',
    '2 - Extinción en más de una modalidad',
  ]),
];

class NihssScreen extends StatefulWidget {
  const NihssScreen({super.key});

  @override
  State<NihssScreen> createState() => _NihssScreenState();
}

class _NihssScreenState extends State<NihssScreen> {
  late List<int> _scores;

  @override
  void initState() {
    super.initState();
    _scores = List.filled(_items.length, 0);
  }

  int get _total => _scores.fold(0, (a, b) => a + b);

  String get _severityLabel {
    if (_total == 0) return 'Sin déficit';
    if (_total <= 4) return 'Déficit menor';
    if (_total <= 15) return 'Déficit moderado';
    if (_total <= 20) return 'Déficit moderado-grave';
    return 'Déficit grave';
  }

  Color get _severityColor {
    if (_total <= 4) return AppColors.severityMild;
    if (_total <= 15) return AppColors.severityModerate;
    return AppColors.severitySevere;
  }

  void _reset() => setState(() => _scores = List.filled(_items.length, 0));

  @override
  Widget build(BuildContext context) {
    return ToolScreenBase(
      title: 'Escala NIHSS',
      onReset: _reset,
      resultWidget: ResultBanner(
        value: '$_total',
        label: _severityLabel,
        color: _severityColor,
      ),
      toolBody: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 4),
            child: ExpansionTile(
              title: Text(item.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              trailing: CircleAvatar(
                radius: 14,
                backgroundColor: _scores[index] > 0 ? AppColors.severitySevere : AppColors.severityMild,
                child: Text('${_scores[index]}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              children: [
                ...List.generate(item.options.length, (optIndex) {
                  return RadioListTile<int>(
                    title: Text(item.options[optIndex], style: const TextStyle(fontSize: 12)),
                    value: optIndex,
                    groupValue: _scores[index],
                    dense: true,
                    onChanged: (v) => setState(() => _scores[index] = v!),
                  );
                }),
              ],
            ),
          );
        },
      ),
      infoBody: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoCard('¿Qué es?',
                'La National Institutes of Health Stroke Scale (NIHSS) es una escala '
                'de valoración neurológica estandarizada que cuantifica la gravedad '
                'del ictus. Evalúa 11 dominios neurológicos con una puntuación '
                'total de 0 a 42 puntos.'),
            _infoCard('Interpretación',
                '0: Sin déficit neurológico\n'
                '1-4: Déficit menor\n'
                '5-15: Déficit moderado\n'
                '16-20: Déficit moderado-grave\n'
                '21-42: Déficit grave\n\n'
                'Una puntuación ≥ 4 suele considerarse indicación de tratamiento '
                'con fibrinolisis intravenosa (en ventana terapéutica).'),
            _infoCard('Cuándo aplicarla',
                'Valoración inicial del paciente con sospecha de ictus.\n'
                'Seguimiento evolutivo del paciente con ictus.\n'
                'Criterio de inclusión/exclusión para tratamiento fibrinolítico.\n'
                'Comunicación estandarizada entre profesionales.\n'
                'Predicción pronóstica funcional.'),
            _infoCard('Limitaciones',
                'Infravalora ictus de circulación posterior.\n'
                'Mayor peso del hemisferio izquierdo (lenguaje).\n'
                'No sustituye la exploración neurológica completa.\n'
                'Variabilidad interobservador en algunos ítems.'),
            _infoCard('Referencias',
                'Brott T, Adams HP, et al. Measurements of acute cerebral infarction: '
                'a clinical examination scale. Stroke. 1989;20(7):864-870.\n\n'
                'National Institutes of Health Stroke Scale (NIHSS). NIH.'),
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
