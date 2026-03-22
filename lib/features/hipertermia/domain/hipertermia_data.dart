import 'package:emerkit/shared/domain/entities/clinical_reference.dart';

class HipertermiaData {
  HipertermiaData._();

  static const Map<String, String> infoSections = {
    'Calambres por calor': 'Espasmos musculares dolorosos, sudoracion profusa, '
        'temperatura normal o ligeramente elevada.\n\n'
        'Tratamiento: reposo en lugar fresco, hidratacion oral '
        '(soluciones electroliticas), estiramiento suave de musculos afectados.',
    'Agotamiento por calor (37-40 C)':
        'Debilidad, fatiga intensa, sudoracion profusa, taquicardia, '
            'hipotension, nauseas, cefalea, piel humeda y palida.\n\n'
            'Tratamiento: retirar del calor, posicion supina con piernas elevadas, '
            'enfriamiento externo, hidratacion oral/IV, monitorizar temperatura.',
    'Golpe de calor (>40 C)':
        'Temperatura >40 C, alteracion nivel de consciencia, piel caliente y SECA, '
            'taquicardia, convulsiones, fracaso multiorganico.\n\n'
            'Tratamiento: EMERGENCIA VITAL, enfriamiento agresivo inmediato, '
            'inmersion en agua fria, hielo en axilas/ingles/cuello, suero IV frio, '
            'traslado urgente. NO administrar antipireticos.',
    'Prevencion': 'Hidratacion frecuente, especialmente en ancianos y ninos.\n'
        'Evitar exposicion solar en horas centrales del dia.\n'
        'Usar ropa ligera y transpirable.\n'
        'Nunca dejar personas o animales en vehiculos cerrados.\n'
        'Aclimatacion progresiva al calor en trabajadores expuestos.',
    'Factores de riesgo': 'Edad extrema (ninos y ancianos).\n'
        'Ejercicio intenso en ambiente caluroso.\n'
        'Farmacos (anticolinergicos, diureticos, betabloqueantes).\n'
        'Enfermedades cronicas (cardiovasculares, diabetes).\n'
        'Deshidratacion previa.\n'
        'Obesidad.',
  };

  static const references = [
    ClinicalReference(
      'Bouchama A, Knochel JP. Heat Stroke. '
      'N Engl J Med. 2002;346:1978-1988.',
    ),
    ClinicalReference(
      'Epstein Y, Yanovich R. Heatstroke. '
      'N Engl J Med. 2019;380:2449-2459.',
    ),
    ClinicalReference(
      'PHTLS: Prehospital Trauma Life Support. 9th Edition. '
      'Jones & Bartlett, 2020.',
    ),
  ];
}
