import 'package:navaja_suiza_sanitaria/shared/domain/entities/clinical_reference.dart';

class HipotermiaData {
  HipotermiaData._();

  static const Map<String, String> infoSections = {
    'Hipotermia':
        'La hipotermia se define como una temperatura corporal central '
        'inferior a 35 C. Puede ser accidental (exposicion ambiental) o '
        'secundaria a otras patologias. La gravedad se clasifica en tres '
        'grados segun la temperatura corporal.',
    'Principio clave':
        '"Nadie esta muerto hasta que esta caliente y muerto". '
        'No se debe declarar el fallecimiento de un paciente hipotermico hasta '
        'que haya sido recalentado.',
    'Clasificacion':
        'Leve (32-35 C): Temblor, vasoconstriccion, taquicardia\n'
        'Moderada (28-32 C): Rigidez, bradicardia, disminucion consciencia\n'
        'Grave (<28 C): Coma, arritmias, apariencia de muerte',
  };

  static const references = [
    ClinicalReference(
      'Brown DJA, et al. Accidental hypothermia. '
      'N Engl J Med. 2012;367:1930-1938.',
    ),
    ClinicalReference(
      'Paal P, et al. Accidental hypothermia: an update. '
      'Scand J Trauma Resusc Emerg Med. 2016;24:111.',
    ),
    ClinicalReference(
      'ERC Guidelines 2025. Resuscitation.',
    ),
    ClinicalReference(
      'PHTLS: Prehospital Trauma Life Support. 9th Edition. '
      'Jones & Bartlett, 2020.',
    ),
  ];
}
