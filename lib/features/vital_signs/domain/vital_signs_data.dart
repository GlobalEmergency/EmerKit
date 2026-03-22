import 'package:navaja_suiza_sanitaria/shared/domain/entities/clinical_reference.dart';

class VitalSignsData {
  VitalSignsData._();

  static const Map<String, String> infoSections = {
    '¿Qué son las constantes vitales?':
        'Las constantes vitales son los parámetros fisiológicos que reflejan el estado '
            'de las funciones básicas del organismo. Incluyen la frecuencia cardíaca (FC), '
            'frecuencia respiratoria (FR), presión arterial (TAS/TAD), saturación de '
            'oxígeno (SpO₂) y temperatura corporal (Tª).',
    'Rangos normales por edad':
        'Los valores normales varían significativamente según la edad del paciente. '
            'Los neonatos y lactantes presentan frecuencias cardíacas y respiratorias más '
            'elevadas y presiones arteriales más bajas que los adultos. Es fundamental '
            'conocer estos rangos para identificar alteraciones de forma precoz.',
    '¿Cuándo son preocupantes?':
        'Los valores fuera de rango pueden indicar situaciones de gravedad:\n\n'
            '- Taquicardia o bradicardia extremas: posible compromiso hemodinámico.\n'
            '- Taquipnea o bradipnea: insuficiencia respiratoria.\n'
            '- Hipotensión: shock o hipovolemia.\n'
            '- SpO₂ < 94%: hipoxemia que requiere oxigenoterapia.\n'
            '- Fiebre > 38°C o hipotermia < 35°C: infección o exposición.',
  };

  static const references = [
    ClinicalReference(
      'PHTLS: Prehospital Trauma Life Support. 9th Ed.',
    ),
    ClinicalReference(
      'PALS Provider Manual. AHA, 2020.',
    ),
  ];
}
