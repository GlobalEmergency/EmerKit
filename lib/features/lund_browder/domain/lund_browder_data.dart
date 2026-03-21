import 'package:navaja_suiza_sanitaria/shared/domain/entities/clinical_reference.dart';

class LundBrowderData {
  LundBrowderData._();

  static const ageGroups = [
    '<1 ano',
    '1 ano',
    '5 anos',
    '10 anos',
    '15 anos',
    'Adulto',
  ];

  static const zoneNames = [
    'Cabeza',
    'Cuello',
    'Tronco anterior',
    'Tronco posterior',
    'Gluteo derecho',
    'Gluteo izquierdo',
    'Genitales',
    'Brazo derecho',
    'Brazo izquierdo',
    'Antebrazo derecho',
    'Antebrazo izquierdo',
    'Mano derecha',
    'Mano izquierda',
    'Muslo derecho',
    'Muslo izquierdo',
    'Pierna derecha',
    'Pierna izquierda',
    'Pie derecho',
    'Pie izquierdo',
  ];

  /// Porcentajes por zona y grupo de edad.
  /// Cada sublista tiene 6 valores: [<1ano, 1ano, 5anos, 10anos, 15anos, adulto].
  static const zonePercentages = <List<double>>[
    [19.0, 17.0, 13.0, 11.0, 9.0, 7.0], // Cabeza
    [2.0, 2.0, 2.0, 2.0, 2.0, 2.0], // Cuello
    [13.0, 13.0, 13.0, 13.0, 13.0, 13.0], // Tronco anterior
    [13.0, 13.0, 13.0, 13.0, 13.0, 13.0], // Tronco posterior
    [2.5, 2.5, 2.5, 2.5, 2.5, 2.5], // Gluteo derecho
    [2.5, 2.5, 2.5, 2.5, 2.5, 2.5], // Gluteo izquierdo
    [1.0, 1.0, 1.0, 1.0, 1.0, 1.0], // Genitales
    [4.0, 4.0, 4.0, 4.0, 4.0, 4.0], // Brazo derecho
    [4.0, 4.0, 4.0, 4.0, 4.0, 4.0], // Brazo izquierdo
    [3.0, 3.0, 3.0, 3.0, 3.0, 3.0], // Antebrazo derecho
    [3.0, 3.0, 3.0, 3.0, 3.0, 3.0], // Antebrazo izquierdo
    [2.5, 2.5, 2.5, 2.5, 2.5, 2.5], // Mano derecha
    [2.5, 2.5, 2.5, 2.5, 2.5, 2.5], // Mano izquierda
    [5.5, 6.5, 8.0, 8.5, 9.0, 9.5], // Muslo derecho
    [5.5, 6.5, 8.0, 8.5, 9.0, 9.5], // Muslo izquierdo
    [5.0, 5.0, 5.5, 6.0, 6.5, 7.0], // Pierna derecha
    [5.0, 5.0, 5.5, 6.0, 6.5, 7.0], // Pierna izquierda
    [3.5, 3.5, 3.5, 3.5, 3.5, 3.5], // Pie derecho
    [3.5, 3.5, 3.5, 3.5, 3.5, 3.5], // Pie izquierdo
  ];

  static const burnLabels = [
    'Sin quemadura',
    'Superficial',
    'Espesor parcial',
    'Espesor total',
  ];

  static const Map<String, String> infoSections = {
    'Que es':
        'La tabla de Lund-Browder es el metodo mas preciso para estimar la superficie corporal '
        'quemada (SCQ). A diferencia de la regla de los 9 de Wallace, tiene en cuenta las '
        'variaciones de proporciones corporales segun la edad del paciente, siendo especialmente '
        'importante en pediatria.',
    'Como funciona':
        'Selecciona el grupo de edad del paciente y marca cada zona corporal afectada con '
        'el grado de quemadura correspondiente:\n\n'
        '0 - Sin quemadura\n'
        '1 - Superficial (epidermica): Eritema, dolor, sin ampollas\n'
        '2 - Espesor parcial (dermica): Ampollas, dolor intenso, exudado\n'
        '3 - Espesor total (subdermica): Escara, indolora, aspecto acartonado\n\n'
        'El porcentaje de cada zona varia segun la edad, reflejando las diferencias '
        'anatomicas reales del paciente.',
    'Clasificacion de gravedad':
        '< 15% SCQ: Quemadura menor\n'
        '15-29% SCQ: Quemadura moderada\n'
        '>= 30% SCQ: Gran quemado (criterio de traslado a unidad de quemados)\n\n'
        'Otros criterios de gravedad independientes del porcentaje:\n'
        '- Quemaduras de espesor total > 5%\n'
        '- Afectacion de cara, manos, pies, genitales o articulaciones\n'
        '- Quemaduras circunferenciales\n'
        '- Lesiones por inhalacion\n'
        '- Quemaduras electricas o quimicas',
  };

  static const references = [
    ClinicalReference(
      'Lund CC, Browder NC. The estimation of areas of burns. '
      'Surgery, Gynecology & Obstetrics. 1944;79:352-358.',
    ),
    ClinicalReference(
      'American Burn Association. Advanced Burn Life Support Course. 2018.',
    ),
    ClinicalReference(
      'ERC Guidelines 2025. Burns management.',
    ),
  ];
}
