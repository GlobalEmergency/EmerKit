import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/screen_info_helper.dart';

class GlucemiaScreen extends StatelessWidget {
  const GlucemiaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Glucemia'),
        actions: [
          buildInfoAction(context, 'Glucemia', [
            buildInfoCard(
              'Metabolismo de la glucosa',
              'La glucosa es la principal fuente de energía del organismo, especialmente del cerebro. La insulina (producida por el páncreas) permite que las células capten la glucosa de la sangre. Un desequilibrio entre la producción de insulina y los niveles de glucosa genera las emergencias diabéticas.',
            ),
            buildInfoCard(
              'Emergencias diabéticas',
              'Hipoglucemia: niveles de glucosa < 70 mg/dL. Es la emergencia diabética más frecuente y potencialmente mortal. Puede causar alteración del nivel de consciencia, convulsiones y coma.\n\n'
              'Hiperglucemia: niveles > 250 mg/dL. Puede evolucionar a cetoacidosis diabética (DM tipo 1) o síndrome hiperosmolar (DM tipo 2), ambas potencialmente letales.',
            ),
            buildInfoCard(
              'Manejo prehospitalario',
              '- Hipoglucemia con paciente consciente: administrar glucosa oral (zumo, azúcar).\n'
              '- Hipoglucemia con paciente inconsciente: glucagón IM o glucosa IV.\n'
              '- Hiperglucemia grave: fluidoterapia IV, monitorización y traslado.\n'
              '- Siempre determinar glucemia en pacientes con alteración del nivel de consciencia.',
            ),
            buildReferencesCard([
              'American Diabetes Association. Standards of Medical Care. 2024.',
              'European Resuscitation Council Guidelines. 2025.',
            ]),
          ]),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard('Hipoglucemia grave', '<40 mg/dL', AppColors.severitySevere,
              'Pérdida de consciencia, convulsiones.\nTratamiento: Glucagón IM / Glucosa IV.'),
          _buildCard('Hipoglucemia', '40-70 mg/dL', AppColors.severityModerate,
              'Temblor, sudoración, taquicardia, confusión.\nTratamiento: Glucosa oral si consciente.'),
          _buildCard('Normal en ayunas', '70-100 mg/dL', AppColors.severityMild, ''),
          _buildCard('Normal postprandial', '70-140 mg/dL', AppColors.severityMild,
              '2 horas después de comer.'),
          _buildCard('Hiperglucemia', '140-250 mg/dL', AppColors.severityModerate,
              'Poliuria, polidipsia, polifagia.\nControl y seguimiento.'),
          _buildCard('Hiperglucemia grave', '>250 mg/dL', AppColors.severitySevere,
              'Riesgo de cetoacidosis diabética o síndrome hiperosmolar.\nBuscar cetonuria. Valorar traslado.'),
          _buildCard('Cetoacidosis diabética', '>300 mg/dL + cetonas', AppColors.severitySevere,
              'Respiración de Kussmaul, aliento cetósico, deshidratación.\nTratamiento: Fluidoterapia IV + Insulina.'),
        ],
      ),
      ),
    );
  }

  Widget _buildCard(String title, String range, Color color, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 8,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(range, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(fontSize: 12)),
            ],
          ],
        ),
        isThreeLine: description.isNotEmpty,
      ),
    );
  }
}
