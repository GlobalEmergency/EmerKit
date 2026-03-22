import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/theme/app_colors.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_info_panel.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_screen_base.dart';

import '../domain/glucemia_data.dart';

class GlucemiaScreen extends StatelessWidget {
  const GlucemiaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ToolScreenBase(
      title: 'Glucemia',
      infoBody: const ToolInfoPanel(
        sections: GlucemiaData.infoSections,
        references: GlucemiaData.references,
      ),
      toolBody: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
              'Hipoglucemia grave',
              '<40 mg/dL',
              AppColors.severitySevere,
              'Pérdida de consciencia, convulsiones.\nTratamiento: Glucagón IM / Glucosa IV.'),
          _buildCard('Hipoglucemia', '40-70 mg/dL', AppColors.severityModerate,
              'Temblor, sudoración, taquicardia, confusión.\nTratamiento: Glucosa oral si consciente.'),
          _buildCard(
              'Normal en ayunas', '70-100 mg/dL', AppColors.severityMild, ''),
          _buildCard('Normal postprandial', '70-140 mg/dL',
              AppColors.severityMild, '2 horas después de comer.'),
          _buildCard(
              'Hiperglucemia',
              '140-250 mg/dL',
              AppColors.severityModerate,
              'Poliuria, polidipsia, polifagia.\nControl y seguimiento.'),
          _buildCard(
              'Hiperglucemia grave',
              '>250 mg/dL',
              AppColors.severitySevere,
              'Riesgo de cetoacidosis diabética o síndrome hiperosmolar.\nBuscar cetonuria. Valorar traslado.'),
          _buildCard(
              'Cetoacidosis diabética',
              '>300 mg/dL + cetonas',
              AppColors.severitySevere,
              'Respiración de Kussmaul, aliento cetósico, deshidratación.\nTratamiento: Fluidoterapia IV + Insulina.'),
        ],
      ),
    );
  }

  Widget _buildCard(
      String title, String range, Color color, String description) {
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
            Text(range,
                style: TextStyle(fontWeight: FontWeight.w600, color: color)),
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
