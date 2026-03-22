import 'package:emerkit/shared/domain/entities/clinical_reference.dart';

/// Static clinical data for the Madrid-DIRECT scale.
class MadridDirectData {
  MadridDirectData._();

  static const infoSections = <String, String>{
    'Escala Madrid-DIRECT':
        'La escala Madrid-DIRECT (DIREct Criteria for Thrombectomy) es una '
            'herramienta de deteccion prehospitalaria de oclusion de gran vaso (OGV). '
            'Evalua 5 items clinicos (+1 punto cada uno) con modificadores de TAS y edad. '
            'Una puntuacion >= 2 indica sospecha de OGV y necesidad de traslado directo '
            'a un hospital con capacidad de trombectomia mecanica.',
    'Items clinicos': 'Brazo no vence gravedad (balance muscular 0-2)\n'
        'Pierna no vence gravedad (balance muscular 0-2)\n'
        'Desviacion de la mirada (parcial o forzada)\n'
        'No obedece ordenes (mutuamente excluyente con heminegligencia)\n'
        'No reconoce deficit / heminegligencia (mutuamente excluyente con no obedece)',
    'Modificadores':
        'TAS: restar 1 punto por cada 10 mmHg por encima de 180 mmHg.\n'
            'Edad: restar 1 punto por cada ano a partir de 85.',
    'Interpretacion': 'Puntuacion >= 2: sospecha de oclusion de gran vaso. '
        'Traslado directo a hospital con trombectomia mecanica.\n\n'
        'Puntuacion < 2: traslado a la unidad de ictus mas cercana.\n\n'
        'Si la puntuacion es < 2 solo por la edad y el paciente tiene excelente '
        'situacion basal, valorar con neurologo la posibilidad de traslado directo.',
  };

  static const references = <ClinicalReference>[
    ClinicalReference(
      'Perez de la Ossa N, et al. Madrid-DIRECT: Validacion de una escala '
      'prehospitalaria para la deteccion de oclusion de gran vaso.',
    ),
    ClinicalReference(
      'Plan de Atencion al Ictus en la Comunidad de Madrid, 2021.',
    ),
  ];
}
