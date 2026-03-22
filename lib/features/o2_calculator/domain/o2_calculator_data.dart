import 'package:navaja_suiza_sanitaria/shared/domain/entities/clinical_reference.dart';

class BottleSize {
  final String label;
  final double liters;
  const BottleSize(this.label, this.liters);
}

class O2CalculatorData {
  O2CalculatorData._();

  static const bottles = [
    BottleSize('1 L', 1),
    BottleSize('2 L', 2),
    BottleSize('3 L', 3),
    BottleSize('5 L', 5),
    BottleSize('7 L', 7),
    BottleSize('10 L', 10),
  ];

  static const Map<String, String> infoSections = {
    'Formula': 'Autonomia = (Volumen botella x Presion util) / Caudal\n\n'
        'Presion util = Presion manometro - 20 bar (reserva de seguridad)',
    'Reserva de seguridad (20 bar)':
        'Siempre se descuentan 20 bar de la presion del manometro como '
            'reserva de seguridad. Esto garantiza un margen antes de que la '
            'botella se agote por completo.',
    'Tamanos de botella habituales':
        '1 L: Botella portatil pequena, emergencias rapidas\n'
            '2 L: Portatil, traslados cortos\n'
            '3 L: Portatil, uso frecuente en ambulancias\n'
            '5 L: Estandar en SVB y SVA\n'
            '7 L: Uso hospitalario y traslados largos\n'
            '10 L: Gran capacidad, hospitales y reserva',
    'Consejos para emergencias':
        'Verifica siempre la presion antes de cada servicio.\n'
            'Lleva una botella de repuesto si el traslado es largo.\n'
            'Ajusta el caudal al minimo eficaz segun SpO2.\n'
            'Recuerda: con menos de 50 bar la botella esta practicamente vacia.\n'
            'Autonomia < 10 min: prepara cambio de botella inmediato.',
  };

  static const references = [
    ClinicalReference(
      'BTS Guideline for Oxygen Use in Healthcare and Emergency Settings. '
      'Thorax. 2017;72:ii1-ii90.',
    ),
    ClinicalReference(
      'PHTLS: Prehospital Trauma Life Support. 9th Edition. '
      'Jones & Bartlett, 2020.',
    ),
    ClinicalReference(
      'O\'Driscoll BR, et al. BTS guideline for oxygen use in adults '
      'in healthcare and emergency settings. Thorax. 2017.',
    ),
  ];
}
