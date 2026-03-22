import 'package:navaja_suiza_sanitaria/shared/domain/entities/clinical_reference.dart';

/// Static clinical data for the Cincinnati Prehospital Stroke Scale.
class CincinnatiData {
  CincinnatiData._();

  static const infoSections = <String, String>{
    'Escala Cincinnati':
        'La Cincinnati Prehospital Stroke Scale (CPSS) es una escala de cribado '
            'prehospitalario de ictus que evalua tres signos: asimetria facial, '
            'fuerza en brazos y alteracion del habla. La presencia de cualquier '
            'hallazgo anormal sugiere ictus y debe activar el Codigo Ictus.',
    'Asimetria facial': 'Pida al paciente que sonria o muestre los dientes.\n'
        'Normal: ambos lados de la cara se mueven igual.\n'
        'Anormal: un lado de la cara no se mueve tan bien como el otro.',
    'Fuerza en brazos':
        'Pida al paciente que extienda ambos brazos con los ojos cerrados '
            'durante 10 segundos.\n'
            'Normal: ambos brazos se mueven igual (o no se mueven).\n'
            'Anormal: un brazo cae o no se mueve igual que el otro.',
    'Habla': 'Pida al paciente que repita una frase sencilla.\n'
        'Normal: pronuncia correctamente las palabras sin dificultad.\n'
        'Anormal: arrastra las palabras, usa palabras incorrectas o no habla.',
    'Cuando activar Codigo Ictus':
        'Cualquier hallazgo anormal en la escala Cincinnati debe activar '
            'el Codigo Ictus.\n\n'
            'Anotar hora de inicio de sintomas.\n'
            'Contactar con neurologo de guardia.',
  };

  static const references = <ClinicalReference>[
    ClinicalReference(
      'Kothari RU, et al. Cincinnati Prehospital Stroke Scale: reproducibility '
      'and validity. Ann Emerg Med. 1999;33(4):373-378.',
    ),
    ClinicalReference(
      'Plan de Atencion al Ictus en la Comunidad de Madrid, 2021.',
    ),
  ];
}
