import 'package:emerkit/shared/domain/entities/clinical_reference.dart';

class RespiratoryRateData {
  RespiratoryRateData._();

  static const Map<String, String> infoSections = {
    'Como funciona':
        'Mantén pulsada la pantalla mientras el paciente inspira y '
            'suelta cuando termine. La app mide la frecuencia respiratoria '
            '(rpm), el ratio inspiracion:espiracion (I:E) y sugiere el '
            'patron respiratorio basandose en la regularidad y duracion '
            'de las fases.',
    'Valores normales (adulto)': 'Bradipnea: < 12 rpm\n'
        'Eupnea (normal): 12-20 rpm\n'
        'Taquipnea: > 20 rpm\n'
        'Taquipnea severa: >= 30 rpm (red flag)',
    'Ratio I:E': 'Normal en reposo: 1:2 a 1:4\n'
        '(la espiracion dura 2-4 veces mas que la inspiracion)\n\n'
        'Invertido (I > E): sugiere patron apneustico u obstructivo',
    'Valores normales por edad': 'Recien nacido: 30-60 rpm\n'
        'Lactante (1-12 meses): 25-50 rpm\n'
        'Nino (1-5 anos): 20-30 rpm\n'
        'Nino (6-12 anos): 18-25 rpm\n'
        'Adolescente/Adulto: 12-20 rpm',
    'Tecnica de valoracion':
        'Contar las respiraciones sin que el paciente lo sepa (para '
            'evitar que modifique su patron respiratorio). Idealmente '
            'simular que se toma el pulso radial mientras se observa el '
            'torax. Contar durante al menos 30 segundos.',
    'Patrones detectables': 'Eupnea: ritmica, rpm 12-20, I:E normal\n'
        'Kussmaul: rapida y profunda (acidosis metabolica)\n'
        'Cheyne-Stokes: ciclica creciente/decreciente con pausas\n'
        'Biot: completamente irregular con pausas\n'
        'Apneustica: inspiracion prolongada (I:E invertido)\n\n'
        'AVISO: La deteccion de patrones es orientativa y no '
        'sustituye la valoracion clinica. Se necesitan al menos '
        '6 respiraciones para detectar Cheyne-Stokes.',
  };

  static const references = [
    ClinicalReference(
      'StatPearls. Physiology, Respiratory Rate. '
      'NCBI Bookshelf NBK537306. 2024.',
    ),
    ClinicalReference(
      'StatPearls. Abnormal Respirations. '
      'NCBI Bookshelf NBK470309. 2024.',
    ),
    ClinicalReference(
      'PHTLS: Prehospital Trauma Life Support. 9th Edition. '
      'Jones & Bartlett, 2020.',
    ),
    ClinicalReference(
      'Bickley LS. Bates\' Guide to Physical Examination. '
      '13th Edition. Wolters Kluwer, 2021.',
    ),
  ];
}
