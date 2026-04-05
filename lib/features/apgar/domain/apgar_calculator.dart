import 'package:emerkit/shared/domain/entities/severity.dart';

class ApgarResult {
  final int appearance;
  final int pulse;
  final int grimace;
  final int activity;
  final int respiration;
  final int total;
  final Severity severity;

  const ApgarResult({
    required this.appearance,
    required this.pulse,
    required this.grimace,
    required this.activity,
    required this.respiration,
    required this.total,
    required this.severity,
  });
}

class ApgarCalculator {
  const ApgarCalculator();

  ApgarResult calculate({
    required int appearance,
    required int pulse,
    required int grimace,
    required int activity,
    required int respiration,
  }) {
    final total = appearance + pulse + grimace + activity + respiration;
    return ApgarResult(
      appearance: appearance,
      pulse: pulse,
      grimace: grimace,
      activity: activity,
      respiration: respiration,
      total: total,
      severity: _severity(total),
    );
  }

  Severity _severity(int total) {
    if (total >= 7) {
      return const Severity(label: 'Normal', level: SeverityLevel.mild);
    }
    if (total >= 4) {
      return const Severity(
          label: 'Depresion moderada', level: SeverityLevel.moderate);
    }
    return const Severity(
        label: 'Depresion severa', level: SeverityLevel.severe);
  }
}
