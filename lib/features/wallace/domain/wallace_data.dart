import 'package:emerkit/shared/domain/entities/clinical_reference.dart';

class WallaceData {
  WallaceData._();

  static const ageGroups = [
    'Adulto',
    '10 anos',
    '5 anos',
    '1 ano',
  ];

  static const zoneNames = [
    'Cabeza y cuello',
    'Extremidad superior derecha',
    'Extremidad superior izquierda',
    'Tronco anterior',
    'Tronco posterior',
    'Extremidad inferior derecha',
    'Extremidad inferior izquierda',
    'Perineo',
  ];

  /// Porcentajes por zona y grupo de edad.
  /// Cada sublista: [Adulto, 10a, 5a, 1a].
  static const zonePercentages = <List<double>>[
    [9.0, 13.0, 15.0, 18.0], // Cabeza y cuello
    [9.0, 9.0, 9.0, 9.0], // EESS derecha
    [9.0, 9.0, 9.0, 9.0], // EESS izquierda
    [18.0, 18.0, 18.0, 18.0], // Tronco anterior
    [18.0, 18.0, 18.0, 18.0], // Tronco posterior
    [18.0, 16.0, 15.0, 14.0], // EEII derecha
    [18.0, 16.0, 15.0, 14.0], // EEII izquierda
    [1.0, 1.0, 1.0, 1.0], // Perineo
  ];

  /// Indices de zonas consideradas especiales (criterio de gravedad
  /// independiente del %SCQ): cabeza/cara y perineo/genitales.
  static const specialZoneIndices = {0, 7};

  static const Map<String, String> infoSections = {
    'Que es': 'La regla de los 9 de Wallace es un metodo rapido para estimar la '
        'superficie corporal quemada (SCQ) en el paciente gran quemado. '
        'Divide el cuerpo en regiones que representan un 9% o multiplos de 9% '
        'de la superficie corporal total. Es el metodo de eleccion en la '
        'valoracion inicial prehospitalaria por su rapidez y sencillez.',
    'Como funciona':
        'Selecciona el grupo de edad del paciente y marca cada zona corporal '
            'afectada. El porcentaje se calcula automaticamente.\n\n'
            'Recuerda que las quemaduras de primer grado (eritema solar) '
            'NO se incluyen en el calculo de SCQ para reposicion hidrica.\n\n'
            'Para valoraciones mas detalladas (especialmente en pediatria), '
            'utiliza la herramienta Lund-Browder disponible en la app.',
    'Regla de los 9 (adulto)': 'Cabeza y cuello: 9%\n'
        'Cada extremidad superior: 9%\n'
        'Tronco anterior: 18%\n'
        'Tronco posterior: 18%\n'
        'Cada extremidad inferior: 18%\n'
        'Perineo: 1%\n'
        'Total: 100%\n\n'
        'Regla de la palma: la palma del paciente (con dedos) equivale '
        'aproximadamente al 1% de su SCT.',
    'Modificacion pediatrica':
        'En ninos, la cabeza es proporcionalmente mayor y las extremidades '
            'inferiores menores:\n\n'
            '1 ano: Cabeza 18%, cada EEII 14%\n'
            '5 anos: Cabeza 15%, cada EEII 15%\n'
            '10 anos: Cabeza 13%, cada EEII 16%\n'
            'Adulto: Cabeza 9%, cada EEII 18%\n\n'
            'Formula rapida: por cada ano >1, restar 1% a cabeza y sumar '
            '0.5% a cada EEII hasta proporciones adultas (~10 anos).',
    'Reposicion hidrica':
        'Si la SCQ es significativa (>=20% adulto, >=10% pediatrico), se calcula '
            'la reposicion hidrica con dos metodos:\n\n'
            'Formula de Parkland: 4 mL x peso(kg) x %SCQ\n'
            '- 50% en primeras 8h (desde hora de quemadura)\n'
            '- 50% en siguientes 16h\n'
            '- Fluido: Ringer Lactato\n\n'
            'Regla del 10 (USAISR): metodo simplificado prehospitalario\n'
            '- Redondear %SCQ a decena mas cercana\n'
            '- Multiplicar por 10 = ritmo en mL/h\n'
            '- Si peso >80kg: +100 mL/h por cada 10kg extra\n\n'
            'Ambos son ritmos INICIALES que deben titularse segun diuresis '
            '(0.5-1 mL/kg/h adulto, 1-1.5 mL/kg/h pediatrico).',
    'Criterios de gravedad': 'Clasificacion por %SCQ:\n'
        '- Adulto: <15% menor, 15-29% moderada, >=30% gran quemado\n'
        '- Pediatrico: <10% menor, 10-19% moderada, >=20% gran quemado\n\n'
        'Criterios de gravedad independientes del %SCQ (ABA):\n'
        '- Quemaduras en cara, manos, pies, genitales, perineo, articulaciones\n'
        '- Quemaduras circunferenciales\n'
        '- Lesion por inhalacion\n'
        '- Quemadura electrica o quimica\n'
        '- Trauma asociado\n'
        '- Comorbilidades significativas\n'
        '- Sospecha de maltrato (pediatria)',
  };

  static const references = [
    ClinicalReference(
      'Wallace AB. The exposure treatment of burns. '
      'Lancet. 1951;1(6653):501-504.',
    ),
    ClinicalReference(
      'Baxter CR, Shires T. Physiological response to crystalloid '
      'resuscitation of severe burns. Ann N Y Acad Sci. 1968;150(3):874-894.',
    ),
    ClinicalReference(
      'Chung KK, et al. Evolution of burn resuscitation in '
      'Operation Iraqi Freedom. J Burn Care Res. 2006;27(5):606-611.',
    ),
    ClinicalReference(
      'ISBI Practice Guidelines Committee. ISBI Practice Guidelines '
      'for Burn Care. Burns. 2016;42(5):953-1021.',
    ),
    ClinicalReference(
      'American Burn Association. Advanced Burn Life Support Course. 2018.',
    ),
    ClinicalReference(
      'Greenhalgh DG. Management of Burns. '
      'N Engl J Med. 2019;380(24):2349-2359.',
    ),
    ClinicalReference(
      'Cartotto R, Greenhalgh DG, Cancio C. Burn State of the Science: '
      'Fluid Resuscitation. J Burn Care Res. 2017;38(3):e596-e604.',
    ),
    ClinicalReference(
      'ERC Guidelines 2025. Burns management.',
    ),
  ];
}
