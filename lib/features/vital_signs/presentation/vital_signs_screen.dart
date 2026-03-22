import 'package:flutter/material.dart';
import 'package:emerkit/shared/presentation/theme/app_colors.dart';
import 'package:emerkit/shared/presentation/widgets/screen_info_helper.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Constantes Vitales'),
        actions: [
          buildInfoAction(context, 'Constantes Vitales', [
            buildInfoCard(
              '¿Qué son las constantes vitales?',
              'Las constantes vitales son los parámetros fisiológicos que reflejan el estado de las funciones básicas del organismo. Incluyen la frecuencia cardíaca (FC), frecuencia respiratoria (FR), presión arterial (TAS/TAD), saturación de oxígeno (SpO₂) y temperatura corporal (Tª).',
            ),
            buildInfoCard(
              'Rangos normales por edad',
              'Los valores normales varían significativamente según la edad del paciente. Los neonatos y lactantes presentan frecuencias cardíacas y respiratorias más elevadas y presiones arteriales más bajas que los adultos. Es fundamental conocer estos rangos para identificar alteraciones de forma precoz.',
            ),
            buildInfoCard(
              '¿Cuándo son preocupantes?',
              'Los valores fuera de rango pueden indicar situaciones de gravedad:\n\n'
                  '- Taquicardia o bradicardia extremas: posible compromiso hemodinámico.\n'
                  '- Taquipnea o bradipnea: insuficiencia respiratoria.\n'
                  '- Hipotensión: shock o hipovolemia.\n'
                  '- SpO₂ < 94%: hipoxemia que requiere oxigenoterapia.\n'
                  '- Fiebre > 38°C o hipotermia < 35°C: infección o exposición.',
            ),
            buildReferencesCard([
              'PHTLS: Prehospital Trauma Life Support. 9th Ed.',
              'PALS Provider Manual. AHA, 2020.',
            ]),
          ]),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView.builder(
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
