import 'package:emerkit/shared/domain/entities/scored_item.dart';
import 'package:emerkit/shared/domain/entities/clinical_reference.dart';

class ApgarData {
  ApgarData._();

  static const appearanceResponses = [
    ScoredItem(label: 'Completamente rosado', score: 2),
    ScoredItem(label: 'Acrocianosis', score: 1),
    ScoredItem(label: 'Cianosis/palidez generalizada', score: 0),
  ];

  static const pulseResponses = [
    ScoredItem(label: '\u2265 100 lpm', score: 2),
    ScoredItem(label: '< 100 lpm', score: 1),
    ScoredItem(label: 'Ausente', score: 0),
  ];

  static const grimaceResponses = [
    ScoredItem(label: 'Llanto vigoroso, tos/estornudo', score: 2),
    ScoredItem(label: 'Mueca, llanto debil', score: 1),
    ScoredItem(label: 'Sin respuesta', score: 0),
  ];

  static const activityResponses = [
    ScoredItem(label: 'Movimiento activo', score: 2),
    ScoredItem(label: 'Flexion debil', score: 1),
    ScoredItem(label: 'Flacido', score: 0),
  ];

  static const respirationResponses = [
    ScoredItem(label: 'Llanto fuerte, regular', score: 2),
    ScoredItem(label: 'Lenta, irregular', score: 1),
    ScoredItem(label: 'Ausente', score: 0),
  ];

  static const infoSections = <String, String>{
    '\u00bfQue es?':
        'El Test de Apgar es una escala de valoracion neonatal desarrollada por Virginia Apgar en 1952. '
            'Evalua cinco parametros del recien nacido (Apariencia, Pulso, Gesticulacion, Actividad y '
            'Respiracion) al minuto 1 y 5 de vida. Es la herramienta estandar para la evaluacion rapida '
            'del estado del neonato tras el nacimiento.',
    'Interpretacion': '7-10: Normal (recien nacido en buenas condiciones)\n'
        '4-6: Depresion moderada (puede requerir estimulacion o soporte)\n'
        '0-3: Depresion severa (requiere reanimacion inmediata)\n\n'
        'Se evalua al minuto 1 (estado inicial) y al minuto 5 (respuesta a reanimacion).\n'
        'Si Apgar a los 5 minutos < 7, se repite cada 5 minutos hasta los 20 minutos.',
    'Cuando aplicarlo': 'Atencion al parto extrahospitalario\n'
        'Nacimiento en domicilio, via publica o ambulancia\n'
        'Valoracion inicial del recien nacido\n'
        'Seguimiento de la respuesta a reanimacion neonatal',
    'Limitaciones': 'Es una valoracion subjetiva y puede variar entre observadores.\n'
        'No predice mortalidad ni morbilidad neurologica a largo plazo por si solo.\n'
        'Prematuros pueden tener puntuaciones mas bajas sin implicar patologia.\n'
        'No sustituye la monitorizacion continua del recien nacido.',
  };

  static const references = [
    ClinicalReference(
      'Apgar V. A proposal for a new method of evaluation of the newborn infant. Curr Res Anesth Analg. 1953;32(4):260-267.',
    ),
    ClinicalReference(
      'American Academy of Pediatrics Committee on Fetus and Newborn. The Apgar Score. Pediatrics. 2015;136(4):819-822.',
    ),
    ClinicalReference(
      'Neonatal Resuscitation Program (NRP). 8th Edition. AAP, 2021.',
    ),
    ClinicalReference(
      'ERC Guidelines 2025. Resuscitation and support of transition of babies at birth.',
    ),
  ];
}
