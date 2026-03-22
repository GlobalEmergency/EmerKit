import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_info_panel.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_screen_base.dart';

import '../domain/posiciones_data.dart';

class _Position {
  final String name;
  final String indication;
  final String description;
  final IconData icon;
  final String? imagePath;

  const _Position({
    required this.name,
    required this.indication,
    required this.description,
    required this.icon,
    this.imagePath,
  });
}

const _positions = [
  _Position(
    name: 'Decúbito supino',
    indication: 'RCP, exploración general',
    description: 'Tumbado boca arriba. Posición base para RCP y exploración.',
    icon: Icons.airline_seat_flat,
    imagePath: 'assets/images/decubito_supino.png',
  ),
  _Position(
    name: 'Decúbito lateral (PLS)',
    indication: 'Inconsciente que respira',
    description: 'Posición Lateral de Seguridad. Previene aspiración.',
    icon: Icons.airline_seat_flat_angled,
    imagePath: 'assets/images/decubito_lateral.png',
  ),
  _Position(
    name: 'Decúbito prono',
    indication: 'SDRA, lesiones en espalda',
    description:
        'Tumbado boca abajo. Mejora oxigenación en distress respiratorio.',
    icon: Icons.airline_seat_flat,
    imagePath: 'assets/images/decubito_prono.png',
  ),
  _Position(
    name: 'Fowler (Semi-incorporado)',
    indication: 'Disnea, ICC, problemas respiratorios',
    description: 'Cabecero elevado 45-60°. Facilita la respiración.',
    icon: Icons.airline_seat_recline_normal,
    imagePath: 'assets/images/posicion_fowler.png',
  ),
  _Position(
    name: 'Fowler alta',
    indication: 'Disnea severa, asma',
    description: 'Cabecero elevado 90°. Máxima expansión torácica.',
    icon: Icons.airline_seat_recline_extra,
    imagePath: 'assets/images/posicion_fowler_alta.png',
  ),
  _Position(
    name: 'Semi-Fowler',
    indication: 'Postoperatorio, embarazo',
    description: 'Cabecero elevado 30°. Confort general.',
    icon: Icons.airline_seat_recline_normal,
    imagePath: 'assets/images/posicion_semifowler.png',
  ),
  _Position(
    name: 'Trendelenburg',
    indication: 'Shock hipovolémico',
    description:
        'Pies más altos que la cabeza (15-30°). Favorece retorno venoso.',
    icon: Icons.airline_seat_legroom_reduced,
    imagePath: 'assets/images/posicion_trendelemburg.png',
  ),
  _Position(
    name: 'Anti-Trendelenburg',
    indication: 'TCE, ACV',
    description: 'Cabeza más alta que pies (15-30°). Reduce PIC.',
    icon: Icons.airline_seat_legroom_extra,
    imagePath: 'assets/images/posicion_antitrendelemburg.png',
  ),
  _Position(
    name: 'Sentado con piernas colgando',
    indication: 'Edema agudo de pulmón',
    description:
        'Sentado en borde de camilla, piernas colgando. Reduce precarga.',
    icon: Icons.chair,
    imagePath: 'assets/images/posicion_sentado_piernas.png',
  ),
  _Position(
    name: 'Fowler con piernas elevadas',
    indication: 'Shock cardiogénico',
    description:
        'Semi-incorporado con piernas elevadas. Mejora retorno venoso sin aumentar precarga pulmonar.',
    icon: Icons.airline_seat_recline_normal,
    imagePath: 'assets/images/posicion_fowler_piernas.png',
  ),
];

class PosicionesScreen extends StatelessWidget {
  const PosicionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ToolScreenBase(
      title: 'Posiciones del Paciente',
      infoBody: const ToolInfoPanel(
        sections: PosicionesData.infoSections,
        references: PosicionesData.references,
      ),
      toolBody: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _positions.length,
        itemBuilder: (context, index) {
          final pos = _positions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              leading:
                  Icon(pos.icon, color: Theme.of(context).colorScheme.primary),
              title: Text(pos.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(pos.indication,
                  style:
                      TextStyle(fontSize: 12, color: Colors.orange.shade700)),
              children: [
                if (pos.imagePath != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        pos.imagePath!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(pos.description),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
