import 'package:navaja_suiza_sanitaria/shared/domain/entities/scored_item.dart';
import 'package:navaja_suiza_sanitaria/shared/domain/entities/clinical_reference.dart';

class NihssCategory {
  final String name;
  final List<ScoredItem> options;
  const NihssCategory({required this.name, required this.options});
}

class NihssData {
  NihssData._();

  static const items = [
    NihssCategory(name: '1a. Nivel de consciencia', options: [
      ScoredItem(label: '0 - Alerta', score: 0),
      ScoredItem(label: '1 - Somnoliento', score: 1),
      ScoredItem(label: '2 - Obnubilacion', score: 2),
      ScoredItem(label: '3 - Coma', score: 3),
    ]),
    NihssCategory(name: '1b. Preguntas (mes y edad)', options: [
      ScoredItem(label: '0 - Responde bien ambas', score: 0),
      ScoredItem(label: '1 - Responde una', score: 1),
      ScoredItem(label: '2 - No responde ninguna', score: 2),
    ]),
    NihssCategory(
      name: '1c. Ordenes (abrir/cerrar ojos, apretar mano)',
      options: [
        ScoredItem(label: '0 - Realiza ambas correctamente', score: 0),
        ScoredItem(label: '1 - Realiza una correctamente', score: 1),
        ScoredItem(label: '2 - No realiza ninguna', score: 2),
      ],
    ),
    NihssCategory(name: '2. Mirada horizontal', options: [
      ScoredItem(label: '0 - Normal', score: 0),
      ScoredItem(label: '1 - Paralisis parcial de la mirada', score: 1),
      ScoredItem(label: '2 - Paralisis total (desviacion forzada)', score: 2),
    ]),
    NihssCategory(name: '3. Campo visual', options: [
      ScoredItem(label: '0 - Normal', score: 0),
      ScoredItem(label: '1 - Hemianopsia parcial', score: 1),
      ScoredItem(label: '2 - Hemianopsia completa', score: 2),
      ScoredItem(label: '3 - Hemianopsia bilateral', score: 3),
    ]),
    NihssCategory(name: '4. Paralisis facial', options: [
      ScoredItem(label: '0 - Normal, simetrica', score: 0),
      ScoredItem(
        label: '1 - Paralisis menor (asimetria al sonreir)',
        score: 1,
      ),
      ScoredItem(label: '2 - Paralisis parcial (macizo inferior)', score: 2),
      ScoredItem(label: '3 - Paralisis completa uni/bilateral', score: 3),
    ]),
    NihssCategory(name: '5a. Motor brazo izquierdo', options: [
      ScoredItem(label: '0 - Mantiene 10 segundos', score: 0),
      ScoredItem(label: '1 - Cae lentamente antes de 10s', score: 1),
      ScoredItem(label: '2 - Esfuerzo contra gravedad', score: 2),
      ScoredItem(label: '3 - Movimiento sin vencer gravedad', score: 3),
      ScoredItem(label: '4 - Ausencia de movimiento', score: 4),
    ]),
    NihssCategory(name: '5b. Motor brazo derecho', options: [
      ScoredItem(label: '0 - Mantiene 10 segundos', score: 0),
      ScoredItem(label: '1 - Cae lentamente antes de 10s', score: 1),
      ScoredItem(label: '2 - Esfuerzo contra gravedad', score: 2),
      ScoredItem(label: '3 - Movimiento sin vencer gravedad', score: 3),
      ScoredItem(label: '4 - Ausencia de movimiento', score: 4),
    ]),
    NihssCategory(name: '6a. Motor pierna izquierda', options: [
      ScoredItem(label: '0 - Mantiene 5 segundos', score: 0),
      ScoredItem(label: '1 - Cae lentamente antes de 5s', score: 1),
      ScoredItem(label: '2 - Esfuerzo contra gravedad', score: 2),
      ScoredItem(label: '3 - Movimiento sin vencer gravedad', score: 3),
      ScoredItem(label: '4 - Ausencia de movimiento', score: 4),
    ]),
    NihssCategory(name: '6b. Motor pierna derecha', options: [
      ScoredItem(label: '0 - Mantiene 5 segundos', score: 0),
      ScoredItem(label: '1 - Cae lentamente antes de 5s', score: 1),
      ScoredItem(label: '2 - Esfuerzo contra gravedad', score: 2),
      ScoredItem(label: '3 - Movimiento sin vencer gravedad', score: 3),
      ScoredItem(label: '4 - Ausencia de movimiento', score: 4),
    ]),
    NihssCategory(name: '7. Ataxia de extremidades', options: [
      ScoredItem(label: '0 - No ataxia', score: 0),
      ScoredItem(label: '1 - Ataxia en una extremidad', score: 1),
      ScoredItem(label: '2 - Ataxia en dos extremidades', score: 2),
    ]),
    NihssCategory(name: '8. Sensibilidad', options: [
      ScoredItem(label: '0 - Normal', score: 0),
      ScoredItem(label: '1 - Deficit leve', score: 1),
      ScoredItem(label: '2 - Deficit total o bilateral', score: 2),
    ]),
    NihssCategory(name: '9. Lenguaje', options: [
      ScoredItem(label: '0 - Normal', score: 0),
      ScoredItem(
        label: '1 - Afasia moderada (comunicacion posible)',
        score: 1,
      ),
      ScoredItem(label: '2 - Afasia grave (no comunicacion)', score: 2),
      ScoredItem(label: '3 - Mudo / comprension global nula', score: 3),
    ]),
    NihssCategory(name: '10. Disartria', options: [
      ScoredItem(label: '0 - Normal', score: 0),
      ScoredItem(label: '1 - Leve-moderada (se comprende)', score: 1),
      ScoredItem(label: '2 - Grave (no se comprende) / anartria', score: 2),
    ]),
    NihssCategory(name: '11. Extincion / Inatencion', options: [
      ScoredItem(label: '0 - Normal', score: 0),
      ScoredItem(label: '1 - Extincion en una modalidad', score: 1),
      ScoredItem(
        label: '2 - Extincion en mas de una modalidad',
        score: 2,
      ),
    ]),
  ];

  static const infoSections = <String, String>{
    '?Que es?':
        'La National Institutes of Health Stroke Scale (NIHSS) es una escala '
        'de valoracion neurologica estandarizada que cuantifica la gravedad '
        'del ictus. Evalua 11 dominios neurologicos con una puntuacion '
        'total de 0 a 42 puntos.',
    'Interpretacion':
        '0: Sin deficit neurologico\n'
        '1-4: Deficit menor\n'
        '5-15: Deficit moderado\n'
        '16-20: Deficit moderado-grave\n'
        '21-42: Deficit grave\n\n'
        'Una puntuacion >= 4 suele considerarse indicacion de tratamiento '
        'con fibrinolisis intravenosa (en ventana terapeutica).',
    'Cuando aplicarla':
        'Valoracion inicial del paciente con sospecha de ictus.\n'
        'Seguimiento evolutivo del paciente con ictus.\n'
        'Criterio de inclusion/exclusion para tratamiento fibrinolitico.\n'
        'Comunicacion estandarizada entre profesionales.\n'
        'Prediccion pronostica funcional.',
    'Limitaciones':
        'Infravalora ictus de circulacion posterior.\n'
        'Mayor peso del hemisferio izquierdo (lenguaje).\n'
        'No sustituye la exploracion neurologica completa.\n'
        'Variabilidad interobservador en algunos items.',
  };

  static const references = [
    ClinicalReference(
      'Brott T, Adams HP, et al. Measurements of acute cerebral infarction: '
      'a clinical examination scale. Stroke. 1989;20(7):864-870.',
    ),
    ClinicalReference(
      'National Institutes of Health Stroke Scale (NIHSS). NIH.',
    ),
  ];
}
