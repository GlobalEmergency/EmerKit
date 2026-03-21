import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/widgets/screen_info_helper.dart';

class _Vendaje {
  final String name;
  final String indication;
  final String technique;
  const _Vendaje(this.name, this.indication, this.technique);
}

const _vendajes = [
  _Vendaje('Circular', 'Fijar apósitos, extremos de vendajes',
      'Vueltas superpuestas sobre sí mismas. Cada vuelta cubre la anterior.'),
  _Vendaje('Espiral', 'Extremidades (zonas uniformes)',
      'Vueltas ascendentes en espiral. Cada vuelta cubre 2/3 de la anterior.'),
  _Vendaje('Espiral con inverso', 'Extremidades (zonas cónicas como antebrazo)',
      'Como espiral pero con pliegue en cada vuelta para adaptarse a la conicidad.'),
  _Vendaje('En ocho (espiga)', 'Articulaciones: codo, rodilla',
      'Vueltas en forma de 8 alrededor de la articulación. Permite flexión parcial.'),
  _Vendaje('Recurrente', 'Muñones, dedos, cabeza',
      'Vueltas de adelante atrás sobre el extremo, fijadas con circulares.'),
  _Vendaje('Velpeau', 'Inmovilización de hombro y brazo',
      'Inmoviliza hombro con brazo pegado al cuerpo. Codo flexionado 90°.'),
  _Vendaje('Mano', 'Heridas en mano',
      'Recurrente sobre dedos + espiral sobre mano + fijación en muñeca en ocho.'),
  _Vendaje('Dedos', 'Heridas en dedos',
      'Recurrente sobre punta del dedo + espiral descendente + fijación en muñeca.'),
  _Vendaje('Muñeca', 'Esguince, heridas en muñeca',
      'Circulares en muñeca + ocho pasando por mano + circulares finales.'),
  _Vendaje('Tobillo', 'Esguince de tobillo',
      'Estribo + circular + ocho alrededor del tobillo. Dejar talón libre.'),
  _Vendaje('Pie', 'Heridas en pie',
      'Recurrente sobre dedos + espiral sobre pie + fijación en tobillo en ocho.'),
  _Vendaje('Tórax', 'Heridas en tórax',
      'Circulares alrededor del tórax. Aplicar en espiración.'),
  _Vendaje('Abdomen', 'Heridas abdominales, evisceración',
      'Circulares ascendentes desde pelvis. No comprimir contenido eviscerado.'),
  _Vendaje('Axila/Hombro', 'Heridas en hombro',
      'Espiga pasando por axila del lado sano + sobre hombro afectado.'),
];

class VendajesScreen extends StatelessWidget {
  const VendajesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendajes'),
        actions: [
          buildInfoAction(context, 'Vendajes', [
            buildInfoCard(
              'Principios del vendaje',
              'El vendaje es una técnica que consiste en envolver una parte del cuerpo con material adecuado para sujetar apósitos, inmovilizar, comprimir o proteger. Los principios fundamentales incluyen: vendar de distal a proximal, mantener tensión uniforme, no cubrir los dedos (para valorar perfusión) y evitar arrugas que provoquen lesiones por presión.',
            ),
            buildInfoCard(
              'Materiales',
              '- Venda de gasa: fijación de apósitos, vendajes no compresivos.\n'
              '- Venda elástica (crepé): vendajes de contención y ligera compresión.\n'
              '- Venda cohesiva: se adhiere a sí misma, ideal para articulaciones.\n'
              '- Venda tubular: protección y fijación en extremidades.\n'
              '- Venda de yeso/fibra de vidrio: inmovilización rígida (uso hospitalario).',
            ),
            buildInfoCard(
              'Vendaje compresivo',
              'El vendaje compresivo se utiliza para el control de hemorragias. Se aplica con presión firme y constante sobre el punto de sangrado. Debe revisarse frecuentemente para asegurar que no compromete la circulación distal (pulsos, sensibilidad, color y temperatura).',
            ),
            buildReferencesCard([
              'Cruz Roja Española. Manual de Primeros Auxilios.',
              'PHTLS: Prehospital Trauma Life Support. 9th Ed.',
            ]),
          ]),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _vendajes.length,
        itemBuilder: (context, index) {
          final v = _vendajes[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              leading: const Icon(Icons.healing, color: Colors.orange),
              title: Text(v.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(v.indication, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(v.technique, style: const TextStyle(fontSize: 14)),
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
