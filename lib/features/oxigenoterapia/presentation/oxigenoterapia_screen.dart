import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/theme/app_colors.dart';
import 'package:navaja_suiza_sanitaria/widgets/screen_info_helper.dart';

class _O2Device {
  final String name;
  final String flowRange;
  final String fio2Range;
  final String description;
  final IconData icon;

  const _O2Device({
    required this.name,
    required this.flowRange,
    required this.fio2Range,
    required this.description,
    required this.icon,
  });
}

const _devices = [
  _O2Device(
    name: 'Gafas nasales',
    flowRange: '1-6 L/min',
    fio2Range: '24-44%',
    description: 'Cada L/min aumenta FiO₂ aprox. 4%.\n1L=24%, 2L=28%, 3L=32%, 4L=36%, 5L=40%, 6L=44%.\nPermite hablar y comer. Cómoda para el paciente.',
    icon: Icons.air,
  ),
  _O2Device(
    name: 'Mascarilla simple',
    flowRange: '5-10 L/min',
    fio2Range: '40-60%',
    description: 'Flujo mínimo 5 L/min para evitar reinhalación de CO₂.\nNo permite FiO₂ precisas.',
    icon: Icons.masks,
  ),
  _O2Device(
    name: 'Mascarilla con reservorio',
    flowRange: '10-15 L/min',
    fio2Range: '60-95%',
    description: 'Bolsa reservorio debe estar inflada antes de colocar.\nFlujo suficiente para que la bolsa no se colapse.\nPara situaciones de emergencia con hipoxia severa.',
    icon: Icons.masks,
  ),
  _O2Device(
    name: 'Mascarilla Venturi',
    flowRange: '4-15 L/min',
    fio2Range: '24-60%',
    description: 'FiO₂ precisa y controlada mediante adaptadores de colores:\nAzul=24% (4L), Amarillo=28% (4L), Blanco=31% (6L),\nVerde=35% (8L), Rosa=40% (10L), Naranja=50% (15L).\nIdeal para EPOC y situaciones que requieren FiO₂ exacta.',
    icon: Icons.tune,
  ),
];

class OxigenoterapiaScreen extends StatelessWidget {
  const OxigenoterapiaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivos O₂'),
        actions: [
          buildInfoAction(context, 'Oxigenoterapia', [
            buildInfoCard(
              'Principios de la oxigenoterapia',
              'La oxigenoterapia consiste en la administración de oxígeno a concentraciones superiores a las del aire ambiente (21%) para corregir la hipoxemia. El objetivo es mantener una SpO₂ adecuada (generalmente > 94%, o 88-92% en pacientes con EPOC).',
            ),
            buildInfoCard(
              'Concepto de FiO₂',
              'La FiO₂ (Fracción Inspirada de Oxígeno) es el porcentaje de oxígeno que recibe el paciente en cada inspiración. El aire ambiente tiene una FiO₂ del 21%. Cada dispositivo permite alcanzar diferentes niveles de FiO₂ según su diseño y el flujo de oxígeno administrado.',
            ),
            buildInfoCard(
              '¿Cuándo usar cada dispositivo?',
              '- Gafas nasales: hipoxemia leve, tratamiento a largo plazo. Cómodas.\n'
              '- Mascarilla simple: hipoxemia moderada que no responde a gafas nasales.\n'
              '- Mascarilla con reservorio: emergencias con hipoxia severa (trauma, PCR).\n'
              '- Mascarilla Venturi: cuando se requiere FiO₂ precisa y controlada (EPOC, insuficiencia respiratoria crónica).',
            ),
            buildReferencesCard([
              'BTS Guideline for Oxygen Use in Healthcare. Thorax. 2017.',
              'PHTLS: Prehospital Trauma Life Support. 9th Ed.',
            ]),
          ]),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          final device = _devices[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(device.icon, color: AppColors.oxigenoterapia, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(device.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoChip('Flujo', device.flowRange),
                      const SizedBox(width: 8),
                      _buildInfoChip('FiO₂', device.fio2Range),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(device.description, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          );
        },
      ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.oxigenoterapia.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.oxigenoterapia)),
        ],
      ),
    );
  }
}
