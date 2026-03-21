import 'package:navaja_suiza_sanitaria/shared/domain/entities/clinical_reference.dart';

class EpiData {
  EpiData._();

  static const Map<String, String> infoSections = {
    'Importancia del EPI':
        'El Equipo de Protección Individual (EPI) es la barrera principal entre el '
        'profesional sanitario y los agentes biológicos, químicos o físicos presentes '
        'en el entorno asistencial. Su uso correcto previene infecciones cruzadas y '
        'protege tanto al profesional como al paciente.',
    'Riesgos de contaminación':
        'La contaminación puede ocurrir durante la colocación, el uso o, sobre todo, '
        'durante la retirada del EPI. Los principales riesgos incluyen:\n\n'
        '- Contacto con superficies contaminadas del EPI al retirarlo.\n'
        '- Autocontaminación por tocarse la cara con guantes usados.\n'
        '- Exposición a aerosoles al retirar la mascarilla incorrectamente.\n'
        '- Salpicaduras a mucosas por falta de protección ocular.',
    'Secuencia correcta':
        'El orden de colocación y retirada es esencial. La colocación va de lo limpio '
        'a lo más expuesto (manos al final). La retirada va de lo más contaminado a '
        'lo menos contaminado, con higiene de manos entre pasos. Cada paso debe '
        'realizarse con cuidado para evitar la autocontaminación.',
  };

  static const references = [
    ClinicalReference(
      'CDC Guidelines for Isolation Precautions and PPE. 2020.',
    ),
    ClinicalReference(
      'WHO: Rational Use of Personal Protective Equipment for COVID-19. 2020.',
    ),
  ];
}
