import 'package:emerkit/shared/domain/entities/severity.dart';

class GlasgowResult {
  final int eye;
  final int verbal;
  final int motor;
  final int total;
  final Severity severity;

  const GlasgowResult({
    required this.eye,
    required this.verbal,
    required this.motor,
    required this.total,
    required this.severity,
  });
}

class GlasgowCalculator {
  const GlasgowCalculator();

  GlasgowResult calculate({
    required int eye,
    required int verbal,
    required int motor,
  }) {
    final total = eye + verbal + motor;
    return GlasgowResult(
      eye: eye,
      verbal: verbal,
      motor: motor,
      total: total,
      severity: _severity(total),
    );
  }

  Severity _severity(int total) {
    if (total >= 13) {
      return const Severity(label: 'Leve', level: SeverityLevel.mild);
    }
    if (total >= 9) {
      return const Severity(label: 'Moderado', level: SeverityLevel.moderate);
    }
    return const Severity(label: 'Grave', level: SeverityLevel.severe);
  }
}
