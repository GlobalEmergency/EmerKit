import 'package:navaja_suiza_sanitaria/shared/domain/entities/clinical_reference.dart';

class TepSide {
  final String title;
  final String description;
  const TepSide({required this.title, required this.description});
}

class TepData {
  TepData._();

  static const sides = [
    TepSide(
      title: 'Apariencia',
      description:
          'Tono, interaccion, consolabilidad, mirada, habla/llanto',
    ),
    TepSide(
      title: 'Trabajo respiratorio',
      description:
          'Sonidos anormales, posicion anormal, retracciones, aleteo nasal',
    ),
    TepSide(
      title: 'Circulacion cutanea',
      description: 'Palidez, cianosis, cutis reticular',
    ),
  ];

  static const infoSections = <String, String>{
    '¿Qué es?':
        'El Triangulo de Evaluacion Pediatrica (TEP) es una herramienta de valoracion '
        'inicial rapida del paciente pediatrico. Permite identificar en segundos el tipo '
        'y gravedad de la situacion clinica mediante la observacion visual y auditiva, '
        'sin necesidad de tocar al paciente.',
    'Lados del triangulo':
        'Apariencia: Valora la funcion del SNC. Se evalua tono muscular, interactividad, '
        'consolabilidad, mirada y habla/llanto. Es el indicador mas importante de gravedad.\n\n'
        'Trabajo respiratorio: Valora la funcion respiratoria. Se buscan sonidos anormales '
        '(estridor, quejido, sibilancias), posicion anormal (tripode, olfateo), retracciones '
        'y aleteo nasal.\n\n'
        'Circulacion cutanea: Valora la funcion circulatoria. Se observa palidez, cianosis '
        'o cutis reticular (moteado) como signos de mala perfusion.',
    'Interpretacion':
        'Estable: Los 3 lados normales.\n\n'
        'Disfuncion del SNC: Solo apariencia alterada.\n'
        'Dificultad respiratoria: Solo trabajo respiratorio alterado.\n'
        'Shock compensado: Solo circulacion alterada.\n\n'
        'Fallo respiratorio: Apariencia + respiracion alteradas.\n'
        'Shock descompensado: Apariencia + circulacion alteradas.\n'
        'Fallo cardiorrespiratorio: Respiracion + circulacion alteradas.\n\n'
        'Parada cardiorrespiratoria: Los 3 lados alterados.',
  };

  static const references = [
    ClinicalReference(
      'Dieckmann RA, Brownstein D, Gausche-Hill M. The Pediatric Assessment Triangle. '
      'Pediatric Emergency Care, 2010.',
    ),
    ClinicalReference(
      'APLS: The Pediatric Emergency Medicine Resource. 6th Edition. Jones & Bartlett, 2020.',
    ),
  ];
}
