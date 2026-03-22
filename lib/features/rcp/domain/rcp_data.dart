import 'package:navaja_suiza_sanitaria/shared/domain/entities/clinical_reference.dart';
import 'package:navaja_suiza_sanitaria/shared/domain/models/medication_protocol.dart';

class RcpData {
  RcpData._();

  static const svaMedications = [
    Medication(
      name: 'Adrenalina',
      dose: '1mg IV/IO',
      interval: Duration(seconds: 240),
      notes: 'Cada 3-5 min',
    ),
    Medication(
      name: 'Amiodarona',
      dose: '300mg IV',
      interval: Duration(seconds: 0),
      maxDoses: 2,
      notes: '2\u00aa dosis: 150mg',
    ),
    Medication(
      name: 'Atropina',
      dose: '0.5mg IV',
      interval: Duration(seconds: 240),
      maxDoses: 6,
      notes: 'Max 3mg total',
    ),
    Medication(
      name: 'Bicarbonato',
      dose: '50mEq IV',
      interval: Duration(seconds: 600),
      notes: 'Segun necesidad',
    ),
  ];

  static const infoSections = {
    'Tecnica de compresion':
        'Comprimir en el centro del pecho (mitad inferior del esternon).\n'
            'Profundidad: 5-6 cm en adultos.\n'
            'Frecuencia: 100-120 compresiones por minuto.\n'
            'Permitir la reexpansion toracica completa entre compresiones.\n'
            'Minimizar las interrupciones de las compresiones.',
    'Ratio 30:2':
        'En RCP estandar con 2 reanimadores o con dispositivo de barrera:\n'
            '\u2022 30 compresiones toracicas seguidas de 2 ventilaciones.\n'
            '\u2022 Cada ventilacion de 1 segundo de duracion.\n'
            '\u2022 Evitar hiperventilacion.\n\n'
            'En RCP con via aerea avanzada (IOT/mascarilla laringea):\n'
            '\u2022 Compresiones continuas a 100-120/min.\n'
            '\u2022 1 ventilacion cada 6 segundos (10/min).',
    'Soporte Vital Basico (SVB)':
        'Secuencia de actuacion ante parada cardiorrespiratoria:\n'
            '1. Comprobar seguridad del entorno.\n'
            '2. Comprobar consciencia y respiracion.\n'
            '3. Llamar al 112 / pedir DEA.\n'
            '4. Iniciar compresiones toracicas (30:2).\n'
            '5. Aplicar DEA en cuanto este disponible.',
    'Soporte Vital Avanzado (SVA)': 'Protocolo SVA durante la RCP:\n'
        '\u2022 Adrenalina 1mg IV/IO cada 3-5 min.\n'
        '\u2022 Amiodarona 300mg IV tras 3er choque (2a dosis: 150mg).\n'
        '\u2022 Buscar y tratar causas reversibles (4H y 4T).\n'
        '\u2022 Asegurar via aerea avanzada.\n'
        '\u2022 Monitorizar con capnografia.',
  };

  static const references = [
    ClinicalReference(
      'European Resuscitation Council Guidelines 2025. Resuscitation.',
    ),
    ClinicalReference(
      'Olasveengen TM, et al. European Resuscitation Council Guidelines '
      '2025: Basic Life Support.',
    ),
    ClinicalReference(
      'Soar J, et al. European Resuscitation Council Guidelines 2025: '
      'Adult Advanced Life Support.',
    ),
  ];
}
