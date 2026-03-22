import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/theme/app_colors.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_info_panel.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_screen_base.dart';

import '../domain/vital_signs_data.dart';

class _AgeGroup {
  final String name;
  final IconData icon;
  final String fc;
  final String fr;
  final String tas;
  final String tad;
  final String spo2;
  final String temp;
  const _AgeGroup(this.name, this.icon, this.fc, this.fr, this.tas, this.tad,
      this.spo2, this.temp);
}

const _groups = [
  _AgeGroup('Adulto', Icons.person, '60-100', '12-20', '100-140', '60-90',
      '>94%', '36-37.5°C'),
  _AgeGroup('Adolescente (12-18)', Icons.person, '60-100', '12-20', '100-130',
      '60-85', '>94%', '36-37.5°C'),
  _AgeGroup('Escolar (5-12 años)', Icons.school, '70-110', '15-25', '90-110',
      '55-75', '>94%', '36-37.5°C'),
  _AgeGroup('Niño (1-5 años)', Icons.boy, '80-130', '20-30', '80-100', '50-70',
      '>94%', '36-37.5°C'),
  _AgeGroup('Lactante (1-12 meses)', Icons.child_care, '100-150', '25-50',
      '70-90', '40-60', '>94%', '36.5-37.5°C'),
  _AgeGroup('Neonato (0-28 días)', Icons.child_friendly, '120-160', '30-60',
      '60-80', '30-50', '>94%', '36.5-37.5°C'),
];

class VitalSignsScreen extends StatelessWidget {
  const VitalSignsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ToolScreenBase(
      title: 'Constantes Vitales',
      infoBody: const ToolInfoPanel(
        sections: VitalSignsData.infoSections,
        references: VitalSignsData.references,
      ),
      toolBody: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _groups.length,
        itemBuilder: (context, index) {
          final g = _groups[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(g.icon, color: AppColors.signosValores),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(g.name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildVitalChip('FC', g.fc, 'lpm', Colors.red),
                      _buildVitalChip('FR', g.fr, 'rpm', Colors.blue),
                      _buildVitalChip('TAS', g.tas, 'mmHg', Colors.orange),
                      _buildVitalChip(
                          'TAD', g.tad, 'mmHg', Colors.orange.shade700),
                      _buildVitalChip('SpO₂', g.spo2, '', Colors.cyan),
                      _buildVitalChip('Tª', g.temp, '', Colors.purple),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVitalChip(String label, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          if (unit.isNotEmpty)
            Text(unit,
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}
