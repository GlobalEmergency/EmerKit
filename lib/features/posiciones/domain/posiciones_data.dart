import 'package:navaja_suiza_sanitaria/shared/domain/entities/clinical_reference.dart';

class PosicionesData {
  PosicionesData._();

  static const Map<String, String> infoSections = {
    'Importancia del posicionamiento':
        'La posición del paciente es una intervención terapéutica en sí misma. Una '
        'correcta posición puede mejorar la ventilación, optimizar la perfusión, '
        'reducir la presión intracraneal, prevenir la aspiración y mejorar el confort '
        'del paciente. La elección depende de la patología y el estado clínico.',
    'Contraindicaciones generales':
        '- Trendelenburg: contraindicado en TCE, ACV, disnea, lesiones torácicas y '
        'embarazo avanzado.\n'
        '- Decúbito supino: contraindicado en pacientes inconscientes que respiran '
        '(riesgo de aspiración) y disnea.\n'
        '- Decúbito prono: contraindicado si no se puede proteger la vía aérea.\n'
        '- Siempre inmovilizar antes de movilizar si se sospecha lesión de columna.',
    'Consideraciones especiales':
        '- Embarazadas (>20 sem): decúbito lateral izquierdo para evitar compresión '
        'de la vena cava.\n'
        '- Trauma: inmovilización en bloque sobre tabla espinal.\n'
        '- Niños: adaptar posiciones a la anatomía pediátrica.\n'
        '- Pacientes obesos: pueden necesitar posiciones más incorporadas para respirar.',
  };

  static const references = [
    ClinicalReference(
      'PHTLS: Prehospital Trauma Life Support. 9th Ed.',
    ),
    ClinicalReference(
      'Tintinalli\'s Emergency Medicine. 9th Ed. 2020.',
    ),
  ];
}
