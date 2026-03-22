import 'package:navaja_suiza_sanitaria/shared/domain/entities/clinical_reference.dart';

class HeartRateData {
  HeartRateData._();

  static const Map<String, String> infoSections = {
    'Como funciona': 'Toca la pantalla cada vez que sientas una pulsacion. '
        'La app calcula los lpm basandose en el intervalo entre toques.',
    'Valores normales (adulto)': 'Bradicardia: < 60 lpm\n'
        'Normal: 60-100 lpm\n'
        'Taquicardia: > 100 lpm',
    'Puntos de palpacion': 'Radial: cara anterior muneca\n'
        'Carotideo: lateral del cuello\n'
        'Femoral: ingle\n'
        'Pedial: dorso del pie',
    'Metodo alternativo':
        'Cuenta pulsaciones durante 15 segundos y multiplica por 4.',
  };

  static const references = [
    ClinicalReference(
      'PHTLS: Prehospital Trauma Life Support. 9th Edition. '
      'Jones & Bartlett, 2020.',
    ),
    ClinicalReference(
      'AHA Guidelines for CPR and ECC. Circulation. 2020.',
    ),
    ClinicalReference(
      'Bickley LS. Bates\' Guide to Physical Examination. '
      '13th Edition. Wolters Kluwer, 2021.',
    ),
  ];
}
