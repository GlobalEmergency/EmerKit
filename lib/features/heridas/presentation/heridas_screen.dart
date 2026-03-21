import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/widgets/screen_info_helper.dart';

class _WoundType {
  final String name;
  final String mechanism;
  final String characteristics;
  final String management;
  final IconData icon;
  final Color color;

  const _WoundType({
    required this.name,
    required this.mechanism,
    required this.characteristics,
    required this.management,
    required this.icon,
    required this.color,
  });
}

const _wounds = [
  _WoundType(
    name: 'Incisa',
    mechanism: 'Objeto cortante (cuchillo, cristal)',
    characteristics: 'Bordes limpios y regulares. Sangrado profuso.',
    management: 'Hemostasia directa. Aproximar bordes. Sutura.',
    icon: Icons.content_cut,
    color: Colors.red,
  ),
  _WoundType(
    name: 'Contusa',
    mechanism: 'Objeto romo (golpe, caída)',
    characteristics: 'Bordes irregulares, aplastamiento tisular. Hematoma.',
    management: 'Limpieza. Frío local. Valorar lesiones profundas.',
    icon: Icons.sports_mma,
    color: Colors.purple,
  ),
  _WoundType(
    name: 'Punzante',
    mechanism: 'Objeto puntiagudo (clavo, aguja)',
    characteristics: 'Orificio pequeño, profundidad variable. Riesgo de lesión interna.',
    management: 'NO retirar objeto enclavado. Inmovilizar. Traslado.',
    icon: Icons.push_pin,
    color: Colors.orange,
  ),
  _WoundType(
    name: 'Abrasión / Erosión',
    mechanism: 'Fricción (caída, rozadura)',
    characteristics: 'Superficial, extensa. Pérdida de epidermis. Muy dolorosa.',
    management: 'Limpieza abundante con suero. Apósito no adherente.',
    icon: Icons.texture,
    color: Colors.amber,
  ),
  _WoundType(
    name: 'Avulsión / Desgarro',
    mechanism: 'Tracción (mordedura, maquinaria)',
    characteristics: 'Bordes muy irregulares. Pérdida de tejido. Colgajos.',
    management: 'Preservar colgajo, cubrir con suero. Si amputación: preservar parte.',
    icon: Icons.warning,
    color: Colors.deepOrange,
  ),
  _WoundType(
    name: 'Quemadura',
    mechanism: 'Térmico, químico, eléctrico, radiación',
    characteristics: 'Clasificación por profundidad y extensión (Lund-Browder).',
    management: 'Enfriar con agua (20 min). No aplicar remedios caseros. Cubrir con apósito estéril.',
    icon: Icons.local_fire_department,
    color: Colors.red,
  ),
];

class HeridasScreen extends StatelessWidget {
  const HeridasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clasificación de Heridas'),
        actions: [
          buildInfoAction(context, 'Heridas', [
            buildInfoCard(
              'Valoración de heridas',
              'La valoración inicial de una herida debe incluir: mecanismo de lesión, localización, profundidad, extensión, presencia de cuerpos extraños, afectación de estructuras profundas (tendones, nervios, vasos) y tiempo transcurrido desde la lesión. Esta información es clave para determinar el tratamiento adecuado.',
            ),
            buildInfoCard(
              'Signos de infección',
              'Los signos clásicos de infección de una herida incluyen:\n\n'
              '- Calor local aumentado.\n'
              '- Enrojecimiento (eritema) perilesional.\n'
              '- Tumefacción (edema).\n'
              '- Dolor creciente o pulsátil.\n'
              '- Supuración purulenta.\n'
              '- Fiebre y malestar general (en infecciones avanzadas).',
            ),
            buildInfoCard(
              'Criterios de derivación',
              '- Heridas profundas con afectación de tendones, nervios o vasos.\n'
              '- Heridas con cuerpos extraños enclavados.\n'
              '- Amputaciones (preservar la parte amputada).\n'
              '- Heridas por mordedura (alto riesgo de infección).\n'
              '- Heridas con signos de infección establecida.\n'
              '- Heridas que requieren sutura (> 6-8 horas de evolución tienen mayor riesgo).',
            ),
            buildReferencesCard([
              'ATLS: Advanced Trauma Life Support. 10th Ed. 2018.',
              'PHTLS: Prehospital Trauma Life Support. 9th Ed.',
            ]),
          ]),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _wounds.length,
        itemBuilder: (context, index) {
          final w = _wounds[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(w.icon, color: w.color),
                      const SizedBox(width: 8),
                      Text(w.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildRow('Mecanismo', w.mechanism),
                  _buildRow('Características', w.characteristics),
                  _buildRow('Manejo', w.management),
                ],
              ),
            ),
          );
        },
      ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
