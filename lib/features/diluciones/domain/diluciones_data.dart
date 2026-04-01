import 'package:emerkit/shared/domain/entities/clinical_reference.dart';

class DilutionPreset {
  final String name;
  final double amountMg;
  final double volumeMl;

  const DilutionPreset(this.name, this.amountMg, this.volumeMl);

  String get presentation =>
      '${_fmtNum(amountMg)} mg / ${_fmtNum(volumeMl)} mL';

  static String _fmtNum(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}

class DilucionesData {
  DilucionesData._();

  static const presets = [
    DilutionPreset('Adrenalina', 1, 1),
    DilutionPreset('Atropina', 1, 1),
    DilutionPreset('Amiodarona', 150, 3),
    DilutionPreset('Dopamina', 200, 5),
    DilutionPreset('Noradrenalina', 10, 10),
    DilutionPreset('Dobutamina', 250, 20),
    DilutionPreset('Midazolam', 15, 3),
    DilutionPreset('Morfina', 10, 1),
  ];

  static const Map<String, String> infoSections = {
    'Formula basica (C1 x V1 = C2 x V2)':
        'La formula de dilucion relaciona la concentracion y el volumen '
            'del farmaco original con la concentracion y volumen deseados.\n\n'
            'C1 = Concentracion inicial (mg/mL)\n'
            'V1 = Volumen del farmaco a extraer (mL)\n'
            'C2 = Concentracion final deseada (mg/mL)\n'
            'V2 = Volumen total de la preparacion (mL)\n\n'
            'V1 = (C2 x V2) / C1',
    'Calculo por peso':
        'Para dosificacion por peso se calcula primero la dosis total:\n\n'
            'Dosis unica: Dosis total (mg) = Peso (kg) x Dosis (mg/kg)\n\n'
            'Perfusion continua: Dosis total (mg) = '
            '(mcg/kg/min / 1000) x Peso (kg) x 60 x Horas\n\n'
            'Ritmo de infusion (mL/h) = Volumen total (mL) / Horas',
    'Diluyentes habituales':
        'Suero Fisiologico (SF 0.9%): Diluyente universal, compatible '
            'con la mayoria de farmacos.\n\n'
            'Suero Glucosado (SG 5%): Para farmacos incompatibles con SF '
            '(ej: amiodarona).\n\n'
            'Agua para inyeccion (API): Para reconstitucion de liofilizados.',
    'Seguridad en la preparacion':
        'Verificar siempre el farmaco, la dosis y la via antes de administrar.\n'
            'Comprobar alergias del paciente.\n'
            'Etiquetar la preparacion con: farmaco, concentracion, fecha y hora.\n'
            'Consultar compatibilidades si se mezclan varios farmacos.\n'
            'En pediatria, usar siempre calculo por peso.',
  };

  static const references = [
    ClinicalReference(
      'ISMP (Institute for Safe Medication Practices). '
      'Guidelines for Standard Order Sets. 2022.',
    ),
    ClinicalReference(
      'Gahart BL, Nazareno AR. Intravenous Medications: '
      'A Handbook for Nurses and Health Professionals. '
      '39th Edition. Elsevier, 2023.',
    ),
    ClinicalReference(
      'AEMPS. Guia de administracion de medicamentos inyectables. '
      'Agencia Espanola de Medicamentos y Productos Sanitarios.',
    ),
    ClinicalReference(
      'SEMES. Manual de Soporte Vital Avanzado. '
      'Farmacologia de urgencias.',
    ),
  ];
}
