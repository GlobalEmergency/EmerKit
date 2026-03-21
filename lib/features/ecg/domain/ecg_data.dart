import 'package:navaja_suiza_sanitaria/shared/domain/entities/clinical_reference.dart';

class EcgData {
  EcgData._();

  static const Map<String, String> infoSections = {
    'Importancia de la colocación':
        'La correcta colocación de los electrodos es fundamental para obtener un trazado '
        'ECG fiable. Una colocación incorrecta puede simular patologías inexistentes '
        '(como infartos o bloqueos) o enmascarar alteraciones reales, llevando a '
        'diagnósticos erróneos y tratamientos inadecuados.',
    'Errores comunes':
        '- Inversión de electrodos de miembros: genera trazados confusos.\n'
        '- Colocación de V1-V2 demasiado altas: simula patología (patrón Brugada).\n'
        '- Electrodos sobre hueso o músculo: artefactos y bajo voltaje.\n'
        '- Piel húmeda o vellosa: mala adherencia y artefactos.\n'
        '- Cables mal conectados: derivaciones intercambiadas.',
    'Sistema Europeo (IEC) vs Americano (AHA)':
        'Existen dos sistemas de codificación por colores para los electrodos de ECG. '
        'El sistema europeo (IEC) utiliza los colores rojo, amarillo, verde y negro, '
        'mientras que el americano (AHA) utiliza blanco, negro, verde y rojo. Es '
        'esencial conocer ambos sistemas para evitar errores en la colocación.',
  };

  static const references = [
    ClinicalReference(
      'AHA/ACC Guidelines for Electrocardiography. Circulation. 2007.',
    ),
    ClinicalReference(
      'IEC 60601 Medical Electrical Equipment Standards.',
    ),
  ];
}
