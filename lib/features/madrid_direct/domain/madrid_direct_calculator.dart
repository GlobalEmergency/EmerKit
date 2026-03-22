/// Pure Dart Madrid-DIRECT scale calculator.
/// NO Flutter imports.
library;

import 'package:navaja_suiza_sanitaria/shared/domain/entities/severity.dart';

class MadridDirectResult {
  final int score;
  final bool requiresThrombectomy;
  final Severity severity;

  const MadridDirectResult({
    required this.score,
    required this.requiresThrombectomy,
    required this.severity,
  });
}

class MadridDirectCalculator {
  const MadridDirectCalculator();

  /// Calculates the Madrid-DIRECT score for large vessel occlusion detection.
  ///
  /// Clinical items (+1 each, max 5 but [noObeyOrders] and [noRecognizeDeficit]
  /// are mutually exclusive -- if both are true, only one is counted):
  /// - [armNoGravity]: arm does not overcome gravity (motor 0-2).
  /// - [legNoGravity]: leg does not overcome gravity (motor 0-2).
  /// - [gazeDeviation]: partial or forced gaze deviation.
  /// - [noObeyOrders]: does not obey simple orders.
  /// - [noRecognizeDeficit]: does not recognize deficit / hemineglect.
  ///
  /// Modifiers (subtract):
  /// - [tas]: systolic blood pressure. Subtract 1 per 10 mmHg above 180.
  /// - [age]: patient age. Subtract 1 per year from 85.
  ///
  /// Score >= 2 indicates suspected large vessel occlusion requiring
  /// direct transfer to a thrombectomy-capable hospital.
  MadridDirectResult calculate({
    required bool armNoGravity,
    required bool legNoGravity,
    required bool gazeDeviation,
    required bool noObeyOrders,
    required bool noRecognizeDeficit,
    required int tas,
    required int age,
  }) {
    // Clinical items: +1 each
    int score = 0;
    if (armNoGravity) score++;
    if (legNoGravity) score++;
    if (gazeDeviation) score++;

    // Mutually exclusive: count at most one
    if (noObeyOrders && noRecognizeDeficit) {
      score++; // Only count one
    } else {
      if (noObeyOrders) score++;
      if (noRecognizeDeficit) score++;
    }

    // TAS modifier: subtract 1 per 10 mmHg above 180
    if (tas >= 180) {
      score -= ((tas - 180) ~/ 10) + 1;
    }

    // Age modifier: subtract 1 per year from 85
    if (age >= 85) {
      score -= (age - 84);
    }

    final requiresThrombectomy = score >= 2;

    final severity = Severity(
      label: requiresThrombectomy
          ? 'Traslado directo a trombectomía'
          : 'Traslado a UI más cercana',
      level:
          requiresThrombectomy ? SeverityLevel.severe : SeverityLevel.moderate,
    );

    return MadridDirectResult(
      score: score,
      requiresThrombectomy: requiresThrombectomy,
      severity: severity,
    );
  }
}
