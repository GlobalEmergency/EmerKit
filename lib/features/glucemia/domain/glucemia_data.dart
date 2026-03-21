import 'package:navaja_suiza_sanitaria/shared/domain/entities/clinical_reference.dart';

class GlucemiaData {
  GlucemiaData._();

  static const Map<String, String> infoSections = {
    'Metabolismo de la glucosa':
        'La glucosa es la principal fuente de energía del organismo, especialmente del '
        'cerebro. La insulina (producida por el páncreas) permite que las células capten '
        'la glucosa de la sangre. Un desequilibrio entre la producción de insulina y los '
        'niveles de glucosa genera las emergencias diabéticas.',
    'Emergencias diabéticas':
        'Hipoglucemia: niveles de glucosa < 70 mg/dL. Es la emergencia diabética más '
        'frecuente y potencialmente mortal. Puede causar alteración del nivel de '
        'consciencia, convulsiones y coma.\n\n'
        'Hiperglucemia: niveles > 250 mg/dL. Puede evolucionar a cetoacidosis diabética '
        '(DM tipo 1) o síndrome hiperosmolar (DM tipo 2), ambas potencialmente letales.',
    'Manejo prehospitalario':
        '- Hipoglucemia con paciente consciente: administrar glucosa oral (zumo, azúcar).\n'
        '- Hipoglucemia con paciente inconsciente: glucagón IM o glucosa IV.\n'
        '- Hiperglucemia grave: fluidoterapia IV, monitorización y traslado.\n'
        '- Siempre determinar glucemia en pacientes con alteración del nivel de consciencia.',
  };

  static const references = [
    ClinicalReference(
      'American Diabetes Association. Standards of Medical Care. 2024.',
    ),
    ClinicalReference(
      'European Resuscitation Council Guidelines. 2025.',
    ),
  ];
}
