/// Pure Dart Cincinnati Prehospital Stroke Scale calculator.
/// NO Flutter imports.
library;

import 'package:emerkit/shared/domain/entities/severity.dart';

class CincinnatiResult {
  final int score;
  final bool suspectedStroke;
  final Severity severity;

  const CincinnatiResult({
    required this.score,
    required this.suspectedStroke,
    required this.severity,
  });
}

class CincinnatiCalculator {
  const CincinnatiCalculator();

  /// Calculates the Cincinnati Prehospital Stroke Scale result.
  ///
  /// Each parameter is true when the finding is **abnormal** (positive).
  /// - [facialDroop]: asymmetric facial movement.
  /// - [armDrift]: one arm drifts or does not move.
  /// - [speech]: slurred or absent speech.
  ///
  /// Any positive finding = suspected stroke.
  CincinnatiResult calculate({
    required bool facialDroop,
    required bool armDrift,
    required bool speech,
  }) {
    final score = [facialDroop, armDrift, speech].where((v) => v).length;
    final suspected = score > 0;

    final severity = Severity(
      label: suspected ? 'Sospecha de ictus' : 'Sin sospecha',
      level: suspected ? SeverityLevel.severe : SeverityLevel.mild,
    );

    return CincinnatiResult(
      score: score,
      suspectedStroke: suspected,
      severity: severity,
    );
  }
}
