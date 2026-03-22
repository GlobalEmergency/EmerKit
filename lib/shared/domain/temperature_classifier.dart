import 'package:emerkit/shared/domain/entities/severity.dart';

class TemperatureResult {
  final String label;
  final Severity severity;
  final List<String> symptoms;
  final List<String> treatment;

  const TemperatureResult({
    required this.label,
    required this.severity,
    required this.symptoms,
    required this.treatment,
  });
}

class TemperatureClassifier {
  /// Clasifica hipotermia segun temperatura corporal central.
  ///
  /// >= 35: NORMAL, 32-35: LEVE, 28-32: MODERADA, <28: GRAVE
  static TemperatureResult classifyHypothermia(double temp) {
    if (temp >= 35) {
      return const TemperatureResult(
        label: 'NORMAL',
        severity: Severity(label: 'Normal', level: SeverityLevel.mild),
        symptoms: [
          'Temperatura corporal normal',
          'Sin signos de hipotermia',
        ],
        treatment: [
          'No requiere tratamiento especifico',
          'Mantener ambiente calido',
        ],
      );
    }
    if (temp >= 32) {
      return const TemperatureResult(
        label: 'LEVE',
        severity:
            Severity(label: 'Hipotermia leve', level: SeverityLevel.moderate),
        symptoms: [
          'Temblor intenso',
          'Vasoconstriccion',
          'Taquicardia, taquipnea',
          'Confusion leve',
        ],
        treatment: [
          'Retirar ropa mojada',
          'Recalentamiento pasivo (mantas, ambiente calido)',
          'Bebidas calientes (si consciente)',
          'Monitorizar',
        ],
      );
    }
    if (temp >= 28) {
      return const TemperatureResult(
        label: 'MODERADA',
        severity:
            Severity(label: 'Hipotermia moderada', level: SeverityLevel.severe),
        symptoms: [
          'Desaparece el temblor',
          'Rigidez muscular',
          'Bradicardia, hipotension',
          'Disminucion nivel consciencia',
          'Pupilas dilatadas',
        ],
        treatment: [
          'Recalentamiento activo externo (mantas termicas)',
          'Manipulacion cuidadosa (riesgo arritmias)',
          'Monitorizacion cardiaca',
          'Traslado hospitalario',
        ],
      );
    }
    return const TemperatureResult(
      label: 'GRAVE',
      severity:
          Severity(label: 'Hipotermia grave', level: SeverityLevel.severe),
      symptoms: [
        'Coma',
        'Arritmias graves (FV)',
        'Rigidez extrema',
        'Apariencia de muerte',
      ],
      treatment: [
        'NO declarar fallecido hasta recalentado',
        '"Nadie esta muerto hasta que esta caliente y muerto"',
        'RCP si no hay signos de vida',
        'Recalentamiento activo interno (hospitalario)',
        'Traslado urgente a hospital con CEC/ECMO',
      ],
    );
  }

  /// Clasifica hipertermia segun temperatura corporal.
  ///
  /// <=37.5: NORMAL, 37.5-38: FEBRICULA, 38-40: AGOTAMIENTO, >40: GOLPE DE CALOR
  static TemperatureResult classifyHyperthermia(double temp) {
    if (temp > 40) {
      return const TemperatureResult(
        label: 'GOLPE DE CALOR',
        severity:
            Severity(label: 'Golpe de calor', level: SeverityLevel.severe),
        symptoms: [
          'Temperatura >40 C',
          'Alteracion nivel de consciencia',
          'Piel caliente y SECA (anhidrosis)',
          'Taquicardia, hipotension',
          'Convulsiones',
          'Fracaso multiorganico',
        ],
        treatment: [
          'EMERGENCIA VITAL',
          'Enfriamiento agresivo inmediato',
          'Inmersion en agua fria si es posible',
          'Hielo en axilas, ingles, cuello',
          'Suero IV frio',
          'Traslado urgente hospitalario',
          'NO administrar antipireticos (no son eficaces)',
        ],
      );
    }
    if (temp >= 38) {
      return const TemperatureResult(
        label: 'AGOTAMIENTO POR CALOR',
        severity: Severity(
            label: 'Agotamiento por calor', level: SeverityLevel.moderate),
        symptoms: [
          'Debilidad, fatiga intensa',
          'Sudoracion profusa',
          'Taquicardia, hipotension',
          'Nauseas, vomitos',
          'Cefalea',
          'Piel humeda y palida',
        ],
        treatment: [
          'Retirar del calor, lugar fresco',
          'Posicion supina, piernas elevadas',
          'Retirar ropa innecesaria',
          'Enfriamiento externo (panos humedos, ventilador)',
          'Hidratacion oral/IV',
          'Monitorizar temperatura',
        ],
      );
    }
    if (temp >= 37.5) {
      return const TemperatureResult(
        label: 'FEBRICULA',
        severity: Severity(label: 'Febricula', level: SeverityLevel.moderate),
        symptoms: [
          'Temperatura ligeramente elevada',
          'Malestar general leve',
          'Sudoracion leve',
        ],
        treatment: [
          'Reposo en lugar fresco',
          'Hidratacion oral',
          'Monitorizar evolucion',
        ],
      );
    }
    return const TemperatureResult(
      label: 'NORMAL',
      severity: Severity(label: 'Normal', level: SeverityLevel.mild),
      symptoms: [
        'Sin sintomas de hipertermia',
        'Temperatura corporal normal',
      ],
      treatment: [
        'No requiere tratamiento',
        'Mantener hidratacion adecuada',
      ],
    );
  }
}
