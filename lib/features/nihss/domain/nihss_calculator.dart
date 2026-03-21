import 'package:navaja_suiza_sanitaria/shared/domain/entities/severity.dart';

class NihssResult {
  final int total;
  final Severity severity;

  const NihssResult({required this.total, required this.severity});
}

class NihssCalculator {
  const NihssCalculator();

  NihssResult calculate(List<int> scores) {
    final total = scores.fold(0, (a, b) => a + b);
    return NihssResult(total: total, severity: _severity(total));
  }

  Severity _severity(int total) {
    if (total == 0) {
      return const Severity(label: 'Sin deficit', level: SeverityLevel.mild);
    }
    if (total <= 4) {
      return const Severity(
        label: 'Deficit menor',
        level: SeverityLevel.mild,
      );
    }
    if (total <= 15) {
      return const Severity(
        label: 'Deficit moderado',
        level: SeverityLevel.moderate,
      );
    }
    if (total <= 20) {
      return const Severity(
        label: 'Deficit moderado-grave',
        level: SeverityLevel.severe,
      );
    }
    return const Severity(
      label: 'Deficit grave',
      level: SeverityLevel.severe,
    );
  }
}
