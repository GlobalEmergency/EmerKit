import 'package:emerkit/shared/domain/entities/scored_item.dart';
import 'package:emerkit/shared/domain/entities/clinical_reference.dart';

class RankinData {
  RankinData._();

  static const levels = [
    ScoredItem(label: 'Asintomatico', description: 'Sin sintomas', score: 0),
    ScoredItem(
      label: 'Sin incapacidad importante',
      description:
          'Capaz de realizar sus actividades habituales a pesar de algun sintoma',
      score: 1,
    ),
    ScoredItem(
      label: 'Incapacidad leve',
      description:
          'Incapaz de realizar alguna de sus actividades previas, pero capaz de valerse por si mismo sin ayuda',
      score: 2,
    ),
    ScoredItem(
      label: 'Incapacidad moderada',
      description:
          'Necesita alguna ayuda pero es capaz de caminar sin asistencia',
      score: 3,
    ),
    ScoredItem(
      label: 'Incapacidad moderadamente grave',
      description:
          'Incapaz de caminar sin ayuda. Incapaz de atender sus necesidades corporales sin ayuda',
      score: 4,
    ),
    ScoredItem(
      label: 'Incapacidad grave',
      description:
          'Totalmente dependiente. Necesita asistencia constante dia y noche',
      score: 5,
    ),
    ScoredItem(label: 'Muerte', description: '', score: 6),
  ];

  static const infoSections = <String, String>{
    '¿Qué es?': 'La Escala de Rankin Modificada (mRS) es una escala de valoracion funcional '
        'que mide el grado de discapacidad o dependencia en las actividades de la vida '
        'diaria tras un ictus u otra patologia neurologica. Es la escala mas utilizada '
        'como variable de resultado en ensayos clinicos de ictus.',
    'Interpretacion': '0: Asintomatico, sin limitaciones\n'
        '1: Sin incapacidad significativa, capaz de realizar actividades habituales\n'
        '2: Incapacidad leve, independiente pero con algunas limitaciones\n'
        '3: Incapacidad moderada, necesita algo de ayuda pero camina solo\n'
        '4: Incapacidad moderada-grave, no puede caminar ni atender necesidades solo\n'
        '5: Incapacidad grave, totalmente dependiente\n'
        '6: Muerte\n\n'
        'Se considera buen resultado funcional una puntuacion de 0-2 '
        '(independiente para actividades basicas de la vida diaria).',
    'Cuando aplicarla':
        'Evaluacion funcional post-ictus (al alta y en seguimiento).\n'
            'Variable de resultado en ensayos clinicos de ictus.\n'
            'Valoracion de la discapacidad en patologia neurologica.\n'
            'Toma de decisiones sobre tratamiento y destino al alta.',
    'Limitaciones':
        'Subjetividad en la diferenciacion entre niveles adyacentes.\n'
            'No capta cambios sutiles dentro de un mismo nivel.\n'
            'No evalua dominios cognitivos ni emocionales especificamente.\n'
            'Variabilidad interobservador, especialmente en niveles intermedios.',
  };

  static const references = [
    ClinicalReference(
      'van Swieten JC, et al. Interobserver agreement for the assessment of '
      'handicap in stroke patients. Stroke. 1988;19(5):604-607.',
    ),
    ClinicalReference(
      'Banks JL, Marotta CA. Outcomes validity and reliability of the modified '
      'Rankin scale. Stroke. 2007;38(3):1091-1096.',
    ),
  ];
}
