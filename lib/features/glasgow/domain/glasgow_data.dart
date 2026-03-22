import 'package:navaja_suiza_sanitaria/shared/domain/entities/scored_item.dart';
import 'package:navaja_suiza_sanitaria/shared/domain/entities/clinical_reference.dart';

class GlasgowData {
  GlasgowData._();

  static const eyeResponses = [
    ScoredItem(label: 'Espontanea', score: 4),
    ScoredItem(label: 'A la voz', score: 3),
    ScoredItem(label: 'Al dolor', score: 2),
    ScoredItem(label: 'Ninguna', score: 1),
  ];

  static const verbalResponses = [
    ScoredItem(label: 'Orientado', score: 5),
    ScoredItem(label: 'Confuso', score: 4),
    ScoredItem(label: 'Palabras inapropiadas', score: 3),
    ScoredItem(label: 'Sonidos incomprensibles', score: 2),
    ScoredItem(label: 'Ninguna', score: 1),
  ];

  static const motorResponses = [
    ScoredItem(label: 'Obedece ordenes', score: 6),
    ScoredItem(label: 'Localiza dolor', score: 5),
    ScoredItem(label: 'Retirada al dolor', score: 4),
    ScoredItem(label: 'Flexion anormal', score: 3),
    ScoredItem(label: 'Extension', score: 2),
    ScoredItem(label: 'Ninguna', score: 1),
  ];

  static const infoSections = <String, String>{
    '¿Qué es?':
        'La Escala de Coma de Glasgow (GCS) es una escala neurologica que valora el nivel de consciencia '
            'de un paciente. Se utiliza en la valoracion inicial y seguimiento de pacientes con traumatismo '
            'craneoencefalico y otras emergencias neurologicas.',
    'Interpretacion': '15: Normal\n'
        '13-14: Leve (paciente alerta, puede presentar confusion)\n'
        '9-12: Moderado (respuesta al dolor, desorientado)\n'
        '3-8: Grave (coma, considerar IOT para proteccion de via aerea)\n\n'
        'GCS de 8 o menor: Considerar intubacion orotraqueal',
    'Limitaciones': 'No valorable en pacientes sedados o relajados.\n'
        'La respuesta verbal no es evaluable en pacientes intubados.\n'
        'Edema facial o periorbitario puede impedir valorar apertura ocular.\n'
        'Lesiones medulares pueden alterar la respuesta motora.',
    'Cuando aplicarla': 'TCE (Traumatismo Craneoencefalico)\n'
        'Alteracion del nivel de consciencia\n'
        'Valoracion neurologica inicial\n'
        'Seguimiento evolutivo del paciente critico',
  };

  static const references = [
    ClinicalReference(
      'Teasdale G, Jennett B. Assessment of coma and impaired consciousness: a practical scale. Lancet. 1974;2(7872):81-84.',
    ),
    ClinicalReference(
      'Teasdale G, et al. The Glasgow Coma Scale at 40 years: standing the test of time. Lancet Neurol. 2014;13(8):844-854.',
    ),
    ClinicalReference('ERC Guidelines 2025. Resuscitation.'),
    ClinicalReference(
      'ATLS: Advanced Trauma Life Support. 10th Edition. ACS, 2018.',
    ),
  ];
}
