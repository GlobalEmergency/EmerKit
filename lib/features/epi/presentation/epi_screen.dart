import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_info_panel.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_screen_base.dart';

import '../domain/epi_data.dart';

class _Step {
  final String title;
  final String description;
  final IconData icon;
  const _Step(this.title, this.description, this.icon);
}

const _donningSteps = [
  _Step('Higiene de manos',
      'Solución hidroalcohólica o lavado con agua y jabón.', Icons.clean_hands),
  _Step(
      'Bata',
      'Colocar bata impermeable, cubriendo torso completamente. Atar por detrás.',
      Icons.checkroom),
  _Step(
      'Mascarilla/Respirador',
      'FFP2/FFP3 según procedimiento. Ajustar clip nasal. Verificar sellado.',
      Icons.masks),
  _Step(
      'Gafas/Pantalla facial',
      'Colocar protección ocular. Ajustar para evitar empañamiento.',
      Icons.visibility),
  _Step('Gorro', 'Cubrir completamente el cabello. Meter las orejas.',
      Icons.face),
  _Step(
      'Guantes',
      'Colocar guantes sobre los puños de la bata. Doble guante si procedimiento de riesgo.',
      Icons.back_hand),
];

const _doffingSteps = [
  _Step(
      'Retirar guantes',
      'Pellizcar exterior del guante. Retirar de dentro a fuera. Desechar.',
      Icons.back_hand),
  _Step('Higiene de manos', 'Con guantes internos o solución hidroalcohólica.',
      Icons.clean_hands),
  _Step(
      'Retirar bata',
      'Desatar. Retirar sin tocar el exterior. Enrollar de dentro a fuera. Desechar.',
      Icons.checkroom),
  _Step(
      'Retirar gafas/pantalla',
      'Retirar por las patillas o goma (no tocar la parte frontal). Desechar o desinfectar.',
      Icons.visibility),
  _Step('Retirar gorro', 'Retirar desde la parte posterior. Desechar.',
      Icons.face),
  _Step(
      'Retirar mascarilla',
      'Retirar por las gomas (no tocar la parte frontal). Desechar.',
      Icons.masks),
  _Step(
      'Higiene de manos',
      'Lavado final con agua y jabón o solución hidroalcohólica.',
      Icons.clean_hands),
];

class EpiScreen extends StatelessWidget {
  const EpiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ToolScreenBase(
        title: 'EPI',
        infoBody: const ToolInfoPanel(
          sections: EpiData.infoSections,
          references: EpiData.references,
        ),
        toolBody: Column(
          children: [
            Material(
              color: Theme.of(context).colorScheme.primary,
              child: const TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: 'Colocación'),
                  Tab(text: 'Retirada'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildStepsList(_donningSteps, Colors.green),
                  _buildStepsList(_doffingSteps, Colors.orange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsList(List<_Step> steps, Color accentColor) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: accentColor,
              child: Text('${index + 1}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text(step.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle:
                Text(step.description, style: const TextStyle(fontSize: 13)),
            trailing: Icon(step.icon, color: accentColor),
          ),
        );
      },
    );
  }
}
