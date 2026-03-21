import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/tool_screen_base.dart';

// Lund-Browder percentages by age group
// Each row: [zone_name, <1yr, 1yr, 5yr, 10yr, 15yr, adult]
const _zoneData = [
  ['Cabeza', 19.0, 17.0, 13.0, 11.0, 9.0, 7.0],
  ['Cuello', 2.0, 2.0, 2.0, 2.0, 2.0, 2.0],
  ['Tronco anterior', 13.0, 13.0, 13.0, 13.0, 13.0, 13.0],
  ['Tronco posterior', 13.0, 13.0, 13.0, 13.0, 13.0, 13.0],
  ['Glúteo derecho', 2.5, 2.5, 2.5, 2.5, 2.5, 2.5],
  ['Glúteo izquierdo', 2.5, 2.5, 2.5, 2.5, 2.5, 2.5],
  ['Genitales', 1.0, 1.0, 1.0, 1.0, 1.0, 1.0],
  ['Brazo derecho', 4.0, 4.0, 4.0, 4.0, 4.0, 4.0],
  ['Brazo izquierdo', 4.0, 4.0, 4.0, 4.0, 4.0, 4.0],
  ['Antebrazo derecho', 3.0, 3.0, 3.0, 3.0, 3.0, 3.0],
  ['Antebrazo izquierdo', 3.0, 3.0, 3.0, 3.0, 3.0, 3.0],
  ['Mano derecha', 2.5, 2.5, 2.5, 2.5, 2.5, 2.5],
  ['Mano izquierda', 2.5, 2.5, 2.5, 2.5, 2.5, 2.5],
  ['Muslo derecho', 5.5, 6.5, 8.0, 8.5, 9.0, 9.5],
  ['Muslo izquierdo', 5.5, 6.5, 8.0, 8.5, 9.0, 9.5],
  ['Pierna derecha', 5.0, 5.0, 5.5, 6.0, 6.5, 7.0],
  ['Pierna izquierda', 5.0, 5.0, 5.5, 6.0, 6.5, 7.0],
  ['Pie derecho', 3.5, 3.5, 3.5, 3.5, 3.5, 3.5],
  ['Pie izquierdo', 3.5, 3.5, 3.5, 3.5, 3.5, 3.5],
];

const _ageGroups = ['<1 año', '1 año', '5 años', '10 años', '15 años', 'Adulto'];

// 0=no burn, 1=superficial, 2=partial, 3=deep
const _burnLabels = ['Sin quemadura', 'Superficial', 'Espesor parcial', 'Espesor total'];
const _burnColors = [Colors.grey, Color(0xFFFFF176), Color(0xFFFFB74D), Color(0xFFE57373)];

class LundBrowderScreen extends StatefulWidget {
  const LundBrowderScreen({super.key});

  @override
  State<LundBrowderScreen> createState() => _LundBrowderScreenState();
}

class _LundBrowderScreenState extends State<LundBrowderScreen> {
  int _selectedAge = 5; // Adult
  final List<int> _burnDegree = List.filled(_zoneData.length, 0);

  double get _totalSCQ {
    double total = 0;
    for (int i = 0; i < _zoneData.length; i++) {
      if (_burnDegree[i] > 0) {
        total += (_zoneData[i][_selectedAge + 1] as double);
      }
    }
    return total;
  }

  Color get _totalColor {
    if (_totalSCQ == 0) return Colors.grey;
    if (_totalSCQ < 15) return AppColors.severityMild;
    if (_totalSCQ < 30) return AppColors.severityModerate;
    return AppColors.severitySevere;
  }

  String get _severityLabel {
    if (_totalSCQ == 0) return 'Selecciona las zonas afectadas';
    if (_totalSCQ < 15) return 'Quemadura menor';
    if (_totalSCQ < 30) return 'Quemadura moderada';
    return 'Gran quemado';
  }

  void _reset() {
    setState(() {
      for (int i = 0; i < _burnDegree.length; i++) {
        _burnDegree[i] = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ToolScreenBase(
      title: 'Lund-Browder',
      onReset: _reset,
      resultWidget: ResultBanner(
        value: '${_totalSCQ.toStringAsFixed(1)}%',
        label: _severityLabel,
        subtitle: 'SCQ - Superficie Corporal Quemada',
        color: _totalColor,
      ),
      toolBody: Column(
        children: [
          // Age selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_ageGroups.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(_ageGroups[i]),
                      selected: _selectedAge == i,
                      selectedColor: AppColors.tecnicas,
                      labelStyle: TextStyle(
                        color: _selectedAge == i ? Colors.white : null,
                        fontWeight: _selectedAge == i ? FontWeight.bold : null,
                        fontSize: 12,
                      ),
                      onSelected: (_) => setState(() => _selectedAge = i),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Body zones list
          Expanded(
            child: ListView.builder(
              itemCount: _zoneData.length,
              itemBuilder: (context, index) {
                final zone = _zoneData[index];
                final name = zone[0] as String;
                final pct = zone[_selectedAge + 1] as double;
                final degree = _burnDegree[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  color: degree > 0 ? _burnColors[degree].withValues(alpha: 0.15) : null,
                  child: ListTile(
                    dense: true,
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text('${pct}% · ${_burnLabels[degree]}', style: TextStyle(fontSize: 12, color: _burnColors[degree])),
                    trailing: SizedBox(
                      width: 160,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: List.generate(4, (d) {
                          return GestureDetector(
                            onTap: () => setState(() => _burnDegree[index] = d),
                            child: Container(
                              width: 36,
                              height: 36,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: degree == d ? _burnColors[d] : _burnColors[d].withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: degree == d
                                    ? Border.all(color: Colors.black26, width: 2)
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  '$d',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: degree == d ? Colors.white : Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (d) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    children: [
                      Container(width: 12, height: 12, color: _burnColors[d]),
                      const SizedBox(width: 4),
                      Text(_burnLabels[d], style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
      infoBody: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoCard('¿Qué es?',
                'La tabla de Lund-Browder es el método más preciso para estimar la superficie corporal '
                'quemada (SCQ). A diferencia de la regla de los 9 de Wallace, tiene en cuenta las '
                'variaciones de proporciones corporales según la edad del paciente, siendo especialmente '
                'importante en pediatría.'),
            _infoCard('Cómo funciona',
                'Selecciona el grupo de edad del paciente y marca cada zona corporal afectada con '
                'el grado de quemadura correspondiente:\n\n'
                '0 - Sin quemadura\n'
                '1 - Superficial (epidérmica): Eritema, dolor, sin ampollas\n'
                '2 - Espesor parcial (dérmica): Ampollas, dolor intenso, exudado\n'
                '3 - Espesor total (subdérmica): Escara, indolora, aspecto acartonado\n\n'
                'El porcentaje de cada zona varía según la edad, reflejando las diferencias '
                'anatómicas reales del paciente.'),
            _infoCard('Clasificación de gravedad',
                '< 15% SCQ: Quemadura menor\n'
                '15-29% SCQ: Quemadura moderada\n'
                '>= 30% SCQ: Gran quemado (criterio de traslado a unidad de quemados)\n\n'
                'Otros criterios de gravedad independientes del porcentaje:\n'
                '- Quemaduras de espesor total > 5%\n'
                '- Afectación de cara, manos, pies, genitales o articulaciones\n'
                '- Quemaduras circunferenciales\n'
                '- Lesiones por inhalación\n'
                '- Quemaduras eléctricas o químicas'),
            _infoCard('Referencias',
                'Lund CC, Browder NC. The estimation of areas of burns. Surgery, Gynecology & Obstetrics. '
                '1944;79:352-358.\n\n'
                'American Burn Association. Advanced Burn Life Support Course. 2018.\n\n'
                'ERC Guidelines 2025. Burns management.'),
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
