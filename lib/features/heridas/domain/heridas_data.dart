import 'package:navaja_suiza_sanitaria/shared/domain/entities/clinical_reference.dart';

class HeridasData {
  HeridasData._();

  static const Map<String, String> infoSections = {
    'Valoración de heridas':
        'La valoración inicial de una herida debe incluir: mecanismo de lesión, '
        'localización, profundidad, extensión, presencia de cuerpos extraños, '
        'afectación de estructuras profundas (tendones, nervios, vasos) y tiempo '
        'transcurrido desde la lesión. Esta información es clave para determinar '
        'el tratamiento adecuado.',
    'Signos de infección':
        'Los signos clásicos de infección de una herida incluyen:\n\n'
        '- Calor local aumentado.\n'
        '- Enrojecimiento (eritema) perilesional.\n'
        '- Tumefacción (edema).\n'
        '- Dolor creciente o pulsátil.\n'
        '- Supuración purulenta.\n'
        '- Fiebre y malestar general (en infecciones avanzadas).',
    'Criterios de derivación':
        '- Heridas profundas con afectación de tendones, nervios o vasos.\n'
        '- Heridas con cuerpos extraños enclavados.\n'
        '- Amputaciones (preservar la parte amputada).\n'
        '- Heridas por mordedura (alto riesgo de infección).\n'
        '- Heridas con signos de infección establecida.\n'
        '- Heridas que requieren sutura (> 6-8 horas de evolución tienen mayor riesgo).',
  };

  static const references = [
    ClinicalReference(
      'ATLS: Advanced Trauma Life Support. 10th Ed. 2018.',
    ),
    ClinicalReference(
      'PHTLS: Prehospital Trauma Life Support. 9th Ed.',
    ),
  ];
}
