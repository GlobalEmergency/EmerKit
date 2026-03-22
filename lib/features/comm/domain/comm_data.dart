import 'package:navaja_suiza_sanitaria/shared/domain/entities/clinical_reference.dart';

class CommData {
  CommData._();

  static const Map<String, String> infoSections = {
    'Importancia de la comunicación estructurada':
        'Los fallos de comunicación son la causa principal de eventos adversos en la '
            'atención sanitaria. La comunicación estructurada reduce errores, mejora la '
            'transferencia de información clínica entre profesionales y garantiza que la '
            'información relevante no se omita durante los traspasos de pacientes.',
    'SBAR vs ISBAR':
        'SBAR (Situation, Background, Assessment, Recommendation) es la herramienta '
            'más extendida. ISBAR añade una "I" inicial de Identificación, separando la '
            'presentación del profesional y del paciente de la situación clínica. Ambas '
            'son igualmente válidas; ISBAR es especialmente útil en comunicaciones '
            'telefónicas donde la identificación inicial es esencial.',
    'Beneficios en emergencias':
        '- Reduce el tiempo de transmisión de información.\n'
            '- Evita omisiones de datos relevantes.\n'
            '- Facilita la toma de decisiones por parte del receptor.\n'
            '- Estandariza la comunicación entre diferentes profesionales y niveles '
            'asistenciales.\n'
            '- Mejora la seguridad del paciente en situaciones de alto estrés.',
  };

  static const references = [
    ClinicalReference(
      'Leonard M, Graham S, Bonacum D. The human factor: the critical importance of '
      'effective teamwork and communication in providing safe care. BMJ Quality & '
      'Safety. 2004.',
    ),
    ClinicalReference(
      'WHO: Communication During Patient Hand-Overs. Patient Safety Solutions. 2007.',
    ),
  ];
}
