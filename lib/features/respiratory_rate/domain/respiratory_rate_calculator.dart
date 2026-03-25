import 'dart:math';
import 'package:emerkit/shared/domain/entities/severity.dart';

// ---------------------------------------------------------------------------
// Simple rpm result (tap-based, kept for backwards compatibility)
// ---------------------------------------------------------------------------

class RespiratoryRateResult {
  final int rpm;
  final Severity severity;

  const RespiratoryRateResult({
    required this.rpm,
    required this.severity,
  });
}

// ---------------------------------------------------------------------------
// Breath model (press & hold)
// ---------------------------------------------------------------------------

class Breath {
  final DateTime inspirationStart;
  final DateTime inspirationEnd;

  const Breath({
    required this.inspirationStart,
    required this.inspirationEnd,
  });

  Duration get inspirationDuration =>
      inspirationEnd.difference(inspirationStart);
}

// ---------------------------------------------------------------------------
// Respiratory pattern classification
// ---------------------------------------------------------------------------

/// Patrones respiratorios detectables.
///
/// Ref: StatPearls – Abnormal Respirations (NBK470309)
enum RespiratoryPatternType {
  eupnea,
  bradypnea,
  tachypnea,
  kussmaul,
  cheyneStokes,
  biot,
  apneustic,
}

class RespiratoryPattern {
  final RespiratoryPatternType type;
  final String label;
  final String description;

  const RespiratoryPattern({
    required this.type,
    required this.label,
    required this.description,
  });

  static const patterns = {
    RespiratoryPatternType.eupnea: RespiratoryPattern(
      type: RespiratoryPatternType.eupnea,
      label: 'Eupnea',
      description: 'Respiracion normal, ritmica',
    ),
    RespiratoryPatternType.bradypnea: RespiratoryPattern(
      type: RespiratoryPatternType.bradypnea,
      label: 'Bradipnea',
      description: 'Respiracion lenta',
    ),
    RespiratoryPatternType.tachypnea: RespiratoryPattern(
      type: RespiratoryPatternType.tachypnea,
      label: 'Taquipnea',
      description: 'Respiracion rapida, superficial',
    ),
    RespiratoryPatternType.kussmaul: RespiratoryPattern(
      type: RespiratoryPatternType.kussmaul,
      label: 'Kussmaul',
      description: 'Respiracion rapida y profunda (acidosis metabolica)',
    ),
    RespiratoryPatternType.cheyneStokes: RespiratoryPattern(
      type: RespiratoryPatternType.cheyneStokes,
      label: 'Cheyne-Stokes',
      description: 'Ciclos crecientes/decrecientes con pausas',
    ),
    RespiratoryPatternType.biot: RespiratoryPattern(
      type: RespiratoryPatternType.biot,
      label: 'Biot',
      description: 'Respiracion irregular e impredecible',
    ),
    RespiratoryPatternType.apneustic: RespiratoryPattern(
      type: RespiratoryPatternType.apneustic,
      label: 'Apneustica',
      description: 'Inspiracion prolongada anormal',
    ),
  };
}

// ---------------------------------------------------------------------------
// Full respiratory analysis result
// ---------------------------------------------------------------------------

class RespiratoryAnalysis {
  final int rpm;
  final double ieRatio;
  final double regularityCV;
  final RespiratoryPattern pattern;
  final Severity severity;

  const RespiratoryAnalysis({
    required this.rpm,
    required this.ieRatio,
    required this.regularityCV,
    required this.pattern,
    required this.severity,
  });

  String get ieRatioFormatted {
    if (ieRatio <= 0) return '--';
    return '1:${ieRatio.toStringAsFixed(1)}';
  }

  String get regularityLabel {
    if (regularityCV < 20) return 'Regular';
    if (regularityCV < 50) return 'Irregular';
    return 'Muy irregular';
  }
}

// ---------------------------------------------------------------------------
// Calculator
// ---------------------------------------------------------------------------

class RespiratoryRateCalculator {
  // ---- Simple tap-based (backwards compatible) ----

  static RespiratoryRateResult? calculateRpm(List<DateTime> taps) {
    if (taps.length < 2) return null;

    final totalMs = taps.last.difference(taps.first).inMilliseconds;
    if (totalMs == 0) return null;

    final rpm = ((taps.length - 1) * 60000 / totalMs).round();
    return RespiratoryRateResult(rpm: rpm, severity: classify(rpm));
  }

  /// Clasifica la frecuencia respiratoria en adultos.
  ///
  /// Ref: StatPearls – Physiology, Respiratory Rate (NBK537306)
  /// - Bradipnea: < 12 rpm
  /// - Eupnea: 12-20 rpm
  /// - Taquipnea: 21-29 rpm
  /// - Taquipnea severa: >= 30 rpm
  static Severity classify(int rpm) {
    if (rpm < 12) {
      return const Severity(
        label: 'Bradipnea',
        level: SeverityLevel.moderate,
      );
    }
    if (rpm <= 20) {
      return const Severity(
        label: 'Eupnea',
        level: SeverityLevel.mild,
      );
    }
    if (rpm < 30) {
      return const Severity(
        label: 'Taquipnea',
        level: SeverityLevel.moderate,
      );
    }
    return const Severity(
      label: 'Taquipnea severa',
      level: SeverityLevel.severe,
    );
  }

  // ---- Full breath analysis (press & hold) ----

  /// Analiza una lista de respiraciones registradas con press & hold.
  ///
  /// Requiere al menos 2 respiraciones completas para calcular rpm y ratio I:E.
  /// La deteccion de Cheyne-Stokes necesita >= 6 respiraciones.
  static RespiratoryAnalysis? analyzeBreathing(List<Breath> breaths) {
    if (breaths.length < 2) return null;

    // --- RPM ---
    final totalMs = breaths.last.inspirationStart
        .difference(breaths.first.inspirationStart)
        .inMilliseconds;
    if (totalMs == 0) return null;
    final rpm = ((breaths.length - 1) * 60000 / totalMs).round();

    // --- I:E ratio (media) ---
    // tE = tiempo desde fin de inspiracion N hasta inicio de inspiracion N+1
    final ieRatios = <double>[];
    final cycleDurations = <double>[];
    for (var i = 0; i < breaths.length - 1; i++) {
      final tI = breaths[i].inspirationDuration.inMilliseconds.toDouble();
      final tE = breaths[i + 1]
          .inspirationStart
          .difference(breaths[i].inspirationEnd)
          .inMilliseconds
          .toDouble();
      if (tI > 0 && tE > 0) {
        ieRatios.add(tE / tI);
      }
      cycleDurations.add(tI + tE);
    }

    final meanIE = ieRatios.isEmpty
        ? 0.0
        : ieRatios.reduce((a, b) => a + b) / ieRatios.length;

    // --- Regularidad (CV de duracion de ciclo) ---
    final cv = _coefficientOfVariation(cycleDurations);

    // --- Duracion inspiratoria media ---
    final meanInspMs = breaths
            .map((b) => b.inspirationDuration.inMilliseconds.toDouble())
            .reduce((a, b) => a + b) /
        breaths.length;
    // Duracion media de un ciclo completo
    final meanCycleMs = cycleDurations.isEmpty
        ? 0.0
        : cycleDurations.reduce((a, b) => a + b) / cycleDurations.length;
    // Proporcion inspiratoria sobre el ciclo
    final inspFraction = meanCycleMs > 0 ? meanInspMs / meanCycleMs : 0.0;

    // --- Deteccion de patron ---
    final hasCheyneStokes =
        breaths.length >= 6 && _detectCrescendoDecrescendo(cycleDurations);

    final patternType = _classifyPattern(
      rpm: rpm,
      meanIE: meanIE,
      cv: cv,
      inspFraction: inspFraction,
      hasCheyneStokes: hasCheyneStokes,
    );

    final pattern = RespiratoryPattern.patterns[patternType]!;
    final severity = _severityForPattern(patternType, rpm);

    return RespiratoryAnalysis(
      rpm: rpm,
      ieRatio: meanIE,
      regularityCV: cv,
      pattern: pattern,
      severity: severity,
    );
  }

  /// Clasifica el patron respiratorio en base a las metricas.
  ///
  /// Criterios basados en:
  /// - StatPearls – Abnormal Respirations (NBK470309)
  /// - StatPearls – Physiology, Respiratory Rate (NBK537306)
  /// - Deranged Physiology – I:E ratio
  static RespiratoryPatternType _classifyPattern({
    required int rpm,
    required double meanIE,
    required double cv,
    required double inspFraction,
    required bool hasCheyneStokes,
  }) {
    // Biot: altamente irregular (CV > 50%)
    // Ref: "clusters of breaths interspersed with periods of apnea" + irregular
    if (cv > 50) return RespiratoryPatternType.biot;

    // Cheyne-Stokes: patron crescendo-decrescendo
    // Ref: "crescendo-decrescendo pattern between apneas"
    if (hasCheyneStokes) return RespiratoryPatternType.cheyneStokes;

    // Apneustica: I:E invertido (inspiracion >= espiracion)
    // Ref: "prolonged gasping inspirations followed by brief expirations"
    // I:E < 1.5 significa que la espiracion es menos de 1.5x la inspiracion
    if (meanIE > 0 && meanIE < 1.0) return RespiratoryPatternType.apneustic;

    // Kussmaul: rpm alta + inspiracion proporcionalmente larga (profunda)
    // Ref: "deep, rapid, and labored breathing"
    // Inspiracion > 40% del ciclo indica respiracion profunda
    if (rpm > 20 && inspFraction > 0.40 && cv < 20) {
      return RespiratoryPatternType.kussmaul;
    }

    // Frecuencia
    if (rpm < 12) return RespiratoryPatternType.bradypnea;
    if (rpm > 20) return RespiratoryPatternType.tachypnea;

    return RespiratoryPatternType.eupnea;
  }

  static Severity _severityForPattern(RespiratoryPatternType type, int rpm) {
    switch (type) {
      case RespiratoryPatternType.eupnea:
        return const Severity(label: 'Normal', level: SeverityLevel.mild);
      case RespiratoryPatternType.bradypnea:
      case RespiratoryPatternType.tachypnea:
      case RespiratoryPatternType.kussmaul:
        return const Severity(label: 'Atencion', level: SeverityLevel.moderate);
      case RespiratoryPatternType.cheyneStokes:
      case RespiratoryPatternType.biot:
      case RespiratoryPatternType.apneustic:
        return const Severity(label: 'Grave', level: SeverityLevel.severe);
    }
  }

  // ---- Helpers estadisticos ----

  /// Coeficiente de variacion (%) de una lista de valores.
  static double _coefficientOfVariation(List<double> values) {
    if (values.length < 2) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    if (mean == 0) return 0;
    final variance =
        values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) /
            values.length;
    return (sqrt(variance) / mean) * 100;
  }

  /// Detecta patron crescendo-decrescendo en la duracion de los ciclos.
  ///
  /// Busca al menos una secuencia donde los ciclos primero crecen
  /// y luego decrecen de forma sostenida (>= 3 creciendo + >= 3 decreciendo).
  static bool _detectCrescendoDecrescendo(List<double> durations) {
    if (durations.length < 5) return false;

    var ascending = 0;
    var descending = 0;
    var peaked = false;

    for (var i = 1; i < durations.length; i++) {
      if (!peaked) {
        if (durations[i] > durations[i - 1]) {
          ascending++;
        } else if (ascending >= 2) {
          peaked = true;
          descending = 1;
        } else {
          ascending = 0;
        }
      } else {
        if (durations[i] < durations[i - 1]) {
          descending++;
        } else {
          if (descending >= 2) return true;
          peaked = false;
          ascending = 1;
          descending = 0;
        }
      }
    }

    return peaked && descending >= 2;
  }
}
