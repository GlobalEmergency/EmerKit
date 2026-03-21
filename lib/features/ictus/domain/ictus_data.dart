import 'package:navaja_suiza_sanitaria/shared/domain/entities/clinical_reference.dart';

/// Static clinical data for Ictus tools (Cincinnati + Madrid-DIRECT).
class IctusData {
  IctusData._();

  static const infoSections = <String, String>{
    'Escala Cincinnati':
        'La Cincinnati Prehospital Stroke Scale (CPSS) es una escala de cribado '
        'prehospitalario de ictus que evalúa tres signos: asimetría facial, '
        'fuerza en brazos y alteración del habla. La presencia de cualquier '
        'hallazgo anormal sugiere ictus y debe activar el Código Ictus.',
    'Escala Madrid-DIRECT':
        'La escala Madrid-DIRECT (DIREct Criteria for Thrombectomy) es una '
        'herramienta de detección prehospitalaria de oclusión de gran vaso (OGV). '
        'Evalúa 5 ítems clínicos (+1 punto cada uno) con modificadores de TAS y edad. '
        'Una puntuación >= 2 indica sospecha de OGV y necesidad de traslado directo '
        'a un hospital con capacidad de trombectomía mecánica.',
    'Ítems clínicos Madrid-DIRECT':
        'Brazo no vence gravedad (balance muscular 0-2)\n'
        'Pierna no vence gravedad (balance muscular 0-2)\n'
        'Desviación de la mirada (parcial o forzada)\n'
        'No obedece órdenes (mutuamente excluyente con heminegligencia)\n'
        'No reconoce déficit / heminegligencia (mutuamente excluyente con no obedece)',
    'Modificadores Madrid-DIRECT':
        'TAS: restar 1 punto por cada 10 mmHg por encima de 180 mmHg.\n'
        'Edad: restar 1 punto por cada año a partir de 85.',
    'Cuándo activar Código Ictus':
        'Cincinnati: cualquier hallazgo anormal en la escala.\n'
        'Madrid-DIRECT: siempre que se active Código Ictus, aplicar la escala '
        'para decidir el destino del traslado.\n\n'
        'Anotar hora de inicio de síntomas.\n'
        'Contactar con neurólogo de guardia.',
  };

  static const references = <ClinicalReference>[
    ClinicalReference(
      'Plan de Atención al Ictus en la Comunidad de Madrid, 2021.',
    ),
    ClinicalReference(
      'Pérez de la Ossa N, et al. Madrid-DIRECT: Validación de una escala '
      'prehospitalaria para la detección de oclusión de gran vaso.',
    ),
    ClinicalReference(
      'Kothari RU, et al. Cincinnati Prehospital Stroke Scale: reproducibility '
      'and validity. Ann Emerg Med. 1999;33(4):373-378.',
    ),
  ];
}
