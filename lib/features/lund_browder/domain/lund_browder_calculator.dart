import 'package:navaja_suiza_sanitaria/shared/domain/entities/severity.dart';
import 'lund_browder_data.dart';

class LundBrowderResult {
  final double totalScq;
  final Severity severity;

  const LundBrowderResult({
    required this.totalScq,
    required this.severity,
  });
}

class LundBrowderCalculator {
  /// Calcula la SCQ (superficie corporal quemada) usando Lund-Browder.
  ///
  /// [burnDegrees] lista de grados de quemadura por zona (0=sin, 1-3=grado).
  /// [ageGroupIndex] indice del grupo de edad (0-5).
  static LundBrowderResult calculate({
    required List<int> burnDegrees,
    required int ageGroupIndex,
  }) {
    double total = 0;
    const zones = LundBrowderData.zonePercentages;

    for (int i = 0; i < zones.length && i < burnDegrees.length; i++) {
      if (burnDegrees[i] > 0) {
        total += zones[i][ageGroupIndex];
      }
    }

    return LundBrowderResult(
      totalScq: total,
      severity: _classify(total),
    );
  }

  static Severity _classify(double scq) {
    if (scq == 0) {
      return const Severity(
        label: 'Sin quemaduras',
        level: SeverityLevel.mild,
      );
    }
    if (scq < 15) {
      return const Severity(
        label: 'Quemadura menor',
        level: SeverityLevel.mild,
      );
    }
    if (scq < 30) {
      return const Severity(
        label: 'Quemadura moderada',
        level: SeverityLevel.moderate,
      );
    }
    return const Severity(
      label: 'Gran quemado',
      level: SeverityLevel.severe,
    );
  }
}
