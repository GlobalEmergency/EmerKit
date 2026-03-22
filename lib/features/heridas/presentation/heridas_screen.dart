import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_info_panel.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_screen_base.dart';

import '../domain/heridas_data.dart';

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
    characteristics:
        'Orificio pequeño, profundidad variable. Riesgo de lesión interna.',
    management: 'NO retirar objeto enclavado. Inmovilizar. Traslado.',
    icon: Icons.push_pin,
    color: Colors.orange,
  ),
  _WoundType(
    name: 'Abrasión / Erosión',
    mechanism: 'Fricción (caída, rozadura)',
    characteristics:
        'Superficial, extensa. Pérdida de epidermis. Muy dolorosa.',
    management: 'Limpieza abundante con suero. Apósito no adherente.',
    icon: Icons.texture,
    color: Colors.amber,
  ),
  _WoundType(
    name: 'Avulsión / Desgarro',
    mechanism: 'Tracción (mordedura, maquinaria)',
    characteristics: 'Bordes muy irregulares. Pérdida de tejido. Colgajos.',
    management:
        'Preservar colgajo, cubrir con suero. Si amputación: preservar parte.',
    icon: Icons.warning,
    color: Colors.deepOrange,
  ),
  _WoundType(
    name: 'Quemadura',
    mechanism: 'Térmico, químico, eléctrico, radiación',
    characteristics:
        'Clasificación por profundidad y extensión (Lund-Browder).',
    management:
        'Enfriar con agua (20 min). No aplicar remedios caseros. Cubrir con apósito estéril.',
    icon: Icons.local_fire_department,
    color: Colors.red,
  ),
];

class HeridasScreen extends StatelessWidget {
  const HeridasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ToolScreenBase(
      title: 'Clasificación de Heridas',
      infoBody: const ToolInfoPanel(
        sections: HeridasData.infoSections,
        references: HeridasData.references,
      ),
      toolBody: ListView.builder(
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
                      Text(w.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildRow(context, 'Mecanismo', w.mechanism),
                  _buildRow(context, 'Características', w.characteristics),
                  _buildRow(context, 'Manejo', w.management),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text.rich(
        TextSpan(
          style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodyMedium?.color),
          children: [
            TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
