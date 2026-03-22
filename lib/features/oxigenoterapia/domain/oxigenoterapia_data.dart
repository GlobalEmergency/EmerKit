import 'package:navaja_suiza_sanitaria/shared/domain/entities/clinical_reference.dart';

class OxigenoterapiaData {
  OxigenoterapiaData._();

  static const Map<String, String> infoSections = {
    'Principios de la oxigenoterapia':
        'La oxigenoterapia consiste en la administración de oxígeno a concentraciones '
            'superiores a las del aire ambiente (21%) para corregir la hipoxemia. El objetivo '
            'es mantener una SpO₂ adecuada (generalmente > 94%, o 88-92% en pacientes con EPOC).',
    'Concepto de FiO₂':
        'La FiO₂ (Fracción Inspirada de Oxígeno) es el porcentaje de oxígeno que recibe '
            'el paciente en cada inspiración. El aire ambiente tiene una FiO₂ del 21%. Cada '
            'dispositivo permite alcanzar diferentes niveles de FiO₂ según su diseño y el '
            'flujo de oxígeno administrado.',
    '¿Cuándo usar cada dispositivo?':
        '- Gafas nasales: hipoxemia leve, tratamiento a largo plazo. Cómodas.\n'
            '- Mascarilla simple: hipoxemia moderada que no responde a gafas nasales.\n'
            '- Mascarilla con reservorio: emergencias con hipoxia severa (trauma, PCR).\n'
            '- Mascarilla Venturi: cuando se requiere FiO₂ precisa y controlada (EPOC, '
            'insuficiencia respiratoria crónica).',
  };

  static const references = [
    ClinicalReference(
      'BTS Guideline for Oxygen Use in Healthcare. Thorax. 2017.',
    ),
    ClinicalReference(
      'PHTLS: Prehospital Trauma Life Support. 9th Ed.',
    ),
  ];
}
