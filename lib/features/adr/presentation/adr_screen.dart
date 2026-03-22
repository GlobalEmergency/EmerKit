import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_info_panel.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_screen_base.dart';

import '../domain/adr_data.dart';

class _AdrClass {
  final String code;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  const _AdrClass(
      this.code, this.name, this.description, this.icon, this.color);
}

const _classes = [
  _AdrClass('1', 'Explosivos', 'Materias y objetos explosivos', Icons.warning,
      Colors.orange),
  _AdrClass(
      '2',
      'Gases',
      '2.1 Inflamables, 2.2 No inflamables/No tóxicos, 2.3 Tóxicos',
      Icons.air,
      Colors.red),
  _AdrClass('3', 'Líquidos inflamables', 'Gasolina, disolventes, pinturas',
      Icons.local_fire_department, Colors.red),
  _AdrClass('4.1', 'Sólidos inflamables', 'Materias autorreactivas',
      Icons.whatshot, Colors.red),
  _AdrClass(
      '4.2',
      'Combustión espontánea',
      'Materias que pueden inflamarse espontáneamente',
      Icons.whatshot,
      Colors.red),
  _AdrClass(
      '4.3',
      'Gases inflamables en contacto con agua',
      'Emiten gases inflamables al contacto con agua',
      Icons.water_drop,
      Colors.blue),
  _AdrClass(
      '5.1',
      'Comburentes',
      'Materias que pueden provocar o favorecer la combustión',
      Icons.science,
      Colors.yellow),
  _AdrClass(
      '5.2',
      'Peróxidos orgánicos',
      'Materias orgánicas con estructura bivalente -O-O-',
      Icons.science,
      Colors.yellow),
  _AdrClass(
      '6.1',
      'Tóxicos',
      'Materias que pueden causar la muerte o daños graves',
      Icons.dangerous,
      Colors.white),
  _AdrClass(
      '6.2',
      'Infecciosos',
      'Materias que contienen microorganismos infecciosos',
      Icons.coronavirus,
      Colors.white),
  _AdrClass('7', 'Radiactivos', 'Materias que emiten radiaciones ionizantes',
      Icons.radio_button_checked, Colors.yellow),
  _AdrClass(
      '8',
      'Corrosivos',
      'Materias que destruyen tejidos vivos o materiales',
      Icons.opacity,
      Colors.black),
  _AdrClass(
      '9',
      'Otros peligros',
      'Materias y objetos que presentan otros peligros',
      Icons.more_horiz,
      Colors.grey),
];

class AdrScreen extends StatelessWidget {
  const AdrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ToolScreenBase(
      title: 'ADR - Mercancías Peligrosas',
      infoBody: const ToolInfoPanel(
        sections: AdrData.infoSections,
        references: AdrData.references,
      ),
      toolBody: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Panel naranja',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Número superior: Código de peligro (Kemler)\n'
                      'Número inferior: Número ONU (identifica la materia)\n\n'
                      'X delante = reacción peligrosa con agua\n'
                      'Repetición de cifra = intensificación del peligro'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text('Clases ADR',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          ..._classes.map((c) => Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: c.color,
                    child: Text(c.code,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: c.color == Colors.white ||
                                  c.color == Colors.yellow
                              ? Colors.black
                              : Colors.white,
                        )),
                  ),
                  title: Text('Clase ${c.code}: ${c.name}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle:
                      Text(c.description, style: const TextStyle(fontSize: 12)),
                ),
              )),
        ],
      ),
    );
  }
}
