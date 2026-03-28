import 'package:emerkit/shared/domain/entities/severity.dart';

class ShockIndexResult {
  final double shockIndex;
  final double modifiedShockIndex;
  final double tam;
  final Severity severity;
  final Severity msiSeverity;
  final double? sipaThreshold;

  const ShockIndexResult({
    required this.shockIndex,
    required this.modifiedShockIndex,
    required this.tam,
    required this.severity,
    required this.msiSeverity,
    this.sipaThreshold,
  });
}

class ShockIndexCalculator {
  const ShockIndexCalculator();

  ShockIndexResult calculate({
    required int heartRate,
    required int systolicBP,
    required int diastolicBP,
    bool isPediatric = false,
    int? ageYears,
  }) {
    final si = heartRate / systolicBP;
    final tam = diastolicBP + (systolicBP - diastolicBP) / 3;
    final msi = heartRate / tam;

    double? sipaThreshold;
    Severity severity;

    if (isPediatric && ageYears != null) {
      sipaThreshold = _sipaThresholdForAge(ageYears);
      severity = _sipaSeverity(si, sipaThreshold);
    } else {
      severity = _adultSeverity(si);
    }

    return ShockIndexResult(
      shockIndex: si,
      modifiedShockIndex: msi,
      tam: tam,
      severity: severity,
      msiSeverity: _msiSeverity(msi),
      sipaThreshold: sipaThreshold,
    );
  }

  static Severity _adultSeverity(double si) {
    if (si < 0.7) {
      return const Severity(label: 'Normal', level: SeverityLevel.mild);
    }
    if (si < 1.0) {
      return const Severity(
          label: 'Normal-alto', level: SeverityLevel.moderate);
    }
    if (si <= 1.3) {
      return const Severity(label: 'Elevado', level: SeverityLevel.severe);
    }
    return const Severity(label: 'Muy elevado', level: SeverityLevel.severe);
  }

  static Severity _msiSeverity(double msi) {
    if (msi >= 0.7 && msi <= 1.3) {
      return const Severity(label: 'Normal', level: SeverityLevel.mild);
    }
    if (msi <= 1.7) {
      return const Severity(label: 'Elevado', level: SeverityLevel.moderate);
    }
    return const Severity(label: 'Muy elevado', level: SeverityLevel.severe);
  }

  static double _sipaThresholdForAge(int age) {
    if (age <= 3) return 1.22;
    if (age <= 6) return 1.2;
    if (age <= 12) return 1.0;
    return 0.9; // 13-17
  }

  static Severity _sipaSeverity(double si, double threshold) {
    if (si < threshold) {
      return const Severity(label: 'Normal', level: SeverityLevel.mild);
    }
    return const Severity(label: 'SIPA elevado', level: SeverityLevel.severe);
  }
}
