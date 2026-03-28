import 'package:emerkit/shared/domain/entities/clinical_reference.dart';

class ShockIndexData {
  ShockIndexData._();

  static const infoSections = <String, String>{
    'Que es':
        'El Indice de Shock (SI) es el cociente entre la frecuencia cardiaca '
            '(FC) y la tension arterial sistolica (TAS). Es una herramienta '
            'rapida para detectar shock e hipovolemia oculta, mas sensible que '
            'FC o TAS por separado, especialmente en la fase compensatoria.',
    'Formulas': 'Indice de Shock (SI) = FC / TAS\n\n'
        'Indice de Shock Modificado (MSI) = FC / TAM\n'
        'TAM = TAD + 1/3 x (TAS - TAD)\n\n'
        'SIPA (pediatrico) = misma formula con umbrales ajustados por edad.',
    'Interpretacion adultos': 'SI < 0.7: Normal\n'
        'SI 0.7 - 0.99: Normal-alto (vigilar)\n'
        'SI 1.0 - 1.3: Elevado - hipovolemia o shock descompensado\n'
        'SI > 1.3: Muy elevado - shock severo, resucitacion inmediata\n\n'
        'MSI 0.7 - 1.3: Rango normal\n'
        'MSI > 1.3: Anormal, mayor riesgo de mortalidad',
    'SIPA pediatrico': '1-3 anos: anormal si >= 1.22\n'
        '4-6 anos: anormal si >= 1.20\n'
        '7-12 anos: anormal si >= 1.00\n'
        '13-17 anos: anormal si >= 0.90',
    'Aplicaciones clinicas':
        'Triaje en trauma: predice necesidad de transfusion masiva e ingreso UCI.\n'
            'Deteccion de hemorragia oculta en fase compensatoria.\n'
            'Screening de sepsis (MSI >= 1.0).\n'
            'Emergencias obstetricas: hemorragia postparto.\n'
            'Triaje en urgencias: asignacion de acuidad y recursos.',
    'Limitaciones': 'No usar como criterio diagnostico unico.\n'
        'Confundido por: betabloqueantes, marcapasos, HTA basal, '
        'embarazo, dolor, ansiedad.\n'
        'Umbrales pediatricos especificos por edad.\n'
        'No validado en pacientes con arritmias o medicacion cronotropica.',
  };

  static const references = [
    ClinicalReference(
      'Allgower M, Burri C. Schockindex. '
      'Dtsch Med Wochenschr. 1967;92(43):1947-1950.',
    ),
    ClinicalReference(
      'Koch E, et al. Shock index in the emergency department: '
      'utility and limitations. Open Access Emerg Med. 2019;11:179-199.',
    ),
    ClinicalReference(
      'Liu YC, et al. Modified shock index and mortality rate of '
      'emergency patients. World J Emerg Med. 2012;3(2):114-117.',
    ),
    ClinicalReference(
      'Acker SN, et al. Shock index, pediatric age-adjusted (SIPA). '
      'J Pediatr Surg. 2015;50(2):331-334.',
    ),
    ClinicalReference(
      'Schroll R, et al. Shock index as predictor of massive '
      'transfusion and mortality. Crit Care. 2023;27(1):61.',
    ),
    ClinicalReference(
      'Mutschler M, et al. The Shock Index revisited — a fast guide '
      'to transfusion requirement? Crit Care. 2013;17(4):R172.',
    ),
  ];
}
