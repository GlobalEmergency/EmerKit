import 'package:navaja_suiza_sanitaria/shared/domain/entities/clinical_reference.dart';

class VendajesData {
  VendajesData._();

  static const Map<String, String> infoSections = {
    'Principios del vendaje':
        'El vendaje es una técnica que consiste en envolver una parte del cuerpo con '
            'material adecuado para sujetar apósitos, inmovilizar, comprimir o proteger. '
            'Los principios fundamentales incluyen: vendar de distal a proximal, mantener '
            'tensión uniforme, no cubrir los dedos (para valorar perfusión) y evitar '
            'arrugas que provoquen lesiones por presión.',
    'Materiales': '- Venda de gasa: fijación de apósitos, vendajes no compresivos.\n'
        '- Venda elástica (crepé): vendajes de contención y ligera compresión.\n'
        '- Venda cohesiva: se adhiere a sí misma, ideal para articulaciones.\n'
        '- Venda tubular: protección y fijación en extremidades.\n'
        '- Venda de yeso/fibra de vidrio: inmovilización rígida (uso hospitalario).',
    'Vendaje compresivo':
        'El vendaje compresivo se utiliza para el control de hemorragias. Se aplica '
            'con presión firme y constante sobre el punto de sangrado. Debe revisarse '
            'frecuentemente para asegurar que no compromete la circulación distal '
            '(pulsos, sensibilidad, color y temperatura).',
  };

  static const references = [
    ClinicalReference(
      'Cruz Roja Española. Manual de Primeros Auxilios.',
    ),
    ClinicalReference(
      'PHTLS: Prehospital Trauma Life Support. 9th Ed.',
    ),
  ];
}
