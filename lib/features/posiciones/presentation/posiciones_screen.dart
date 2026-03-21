import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/widgets/screen_info_helper.dart';

class _Position {
  final String name;
  final String indication;
  final String description;
  final IconData icon;

  const _Position({
    required this.name,
    required this.indication,
    required this.description,
    required this.icon,
  });
}

const _positions = [
  _Position(
    name: 'Decúbito supino',
    indication: 'RCP, exploración general',
    description: 'Tumbado boca arriba. Posición base para RCP y exploración.',
    icon: Icons.airline_seat_flat,
  ),
  _Position(
    name: 'Decúbito lateral (PLS)',
    indication: 'Inconsciente que respira',
    description: 'Posición Lateral de Seguridad. Previene aspiración.',
    icon: Icons.airline_seat_flat_angled,
  ),
  _Position(
    name: 'Decúbito prono',
    indication: 'SDRA, lesiones en espalda',
    description: 'Tumbado boca abajo. Mejora oxigenación en distress respiratorio.',
    icon: Icons.airline_seat_flat,
  ),
  _Position(
    name: 'Fowler (Semi-incorporado)',
    indication: 'Disnea, ICC, problemas respiratorios',
    description: 'Cabecero elevado 45-60°. Facilita la respiración.',
    icon: Icons.airline_seat_recline_normal,
  ),
  _Position(
    name: 'Fowler alta',
    indication: 'Disnea severa, asma',
    description: 'Cabecero elevado 90°. Máxima expansión torácica.',
    icon: Icons.airline_seat_recline_extra,
  ),
  _Position(
    name: 'Semi-Fowler',
    indication: 'Postoperatorio, embarazo',
    description: 'Cabecero elevado 30°. Confort general.',
    icon: Icons.airline_seat_recline_normal,
  ),
  _Position(
    name: 'Trendelenburg',
    indication: 'Shock hipovolémico',
    description: 'Pies más altos que la cabeza (15-30°). Favorece retorno venoso.',
    icon: Icons.airline_seat_legroom_reduced,
  ),
  _Position(
    name: 'Anti-Trendelenburg',
    indication: 'TCE, ACV',
    description: 'Cabeza más alta que pies (15-30°). Reduce PIC.',
    icon: Icons.airline_seat_legroom_extra,
  ),
  _Position(
    name: 'Sentado con piernas colgando',
    indication: 'Edema agudo de pulmón',
    description: 'Sentado en borde de camilla, piernas colgando. Reduce precarga.',
    icon: Icons.chair,
  ),
  _Position(
    name: 'Fowler con piernas elevadas',
    indication: 'Shock cardiogénico',
    description: 'Semi-incorporado con piernas elevadas. Mejora retorno venoso sin aumentar precarga pulmonar.',
    icon: Icons.airline_seat_recline_normal,
  ),
];

class PosicionesScreen extends StatelessWidget {
  const PosicionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posiciones del Paciente'),
        actions: [
          buildInfoAction(context, 'Posiciones del Paciente', [
            buildInfoCard(
              'Importancia del posicionamiento',
              'La posición del paciente es una intervención terapéutica en sí misma. Una correcta posición puede mejorar la ventilación, optimizar la perfusión, reducir la presión intracraneal, prevenir la aspiración y mejorar el confort del paciente. La elección depende de la patología y el estado clínico.',
            ),
            buildInfoCard(
              'Contraindicaciones generales',
              '- Trendelenburg: contraindicado en TCE, ACV, disnea, lesiones torácicas y embarazo avanzado.\n'
              '- Decúbito supino: contraindicado en pacientes inconscientes que respiran (riesgo de aspiración) y disnea.\n'
              '- Decúbito prono: contraindicado si no se puede proteger la vía aérea.\n'
              '- Siempre inmovilizar antes de movilizar si se sospecha lesión de columna.',
            ),
            buildInfoCard(
              'Consideraciones especiales',
              '- Embarazadas (>20 sem): decúbito lateral izquierdo para evitar compresión de la vena cava.\n'
              '- Trauma: inmovilización en bloque sobre tabla espinal.\n'
              '- Niños: adaptar posiciones a la anatomía pediátrica.\n'
              '- Pacientes obesos: pueden necesitar posiciones más incorporadas para respirar.',
            ),
            buildReferencesCard([
              'PHTLS: Prehospital Trauma Life Support. 9th Ed.',
              'Tintinalli\'s Emergency Medicine. 9th Ed. 2020.',
            ]),
          ]),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _positions.length,
        itemBuilder: (context, index) {
          final pos = _positions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              leading: Icon(pos.icon, color: Theme.of(context).colorScheme.primary),
              title: Text(pos.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(pos.indication,
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade700)),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(pos.description),
                ),
              ],
            ),
          );
        },
      ),
      ),
    );
  }
}
