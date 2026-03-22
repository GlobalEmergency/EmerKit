import 'package:emerkit/shared/domain/entities/severity.dart';

class RankinResult {
  final int score;
  final String title;
  final String independence;
  final Severity severity;

  const RankinResult({
    required this.score,
    required this.title,
    required this.independence,
    required this.severity,
  });
}

class RankinCalculator {
  const RankinCalculator();

  static const _titles = [
    'Asintomatico',
    'Sin incapacidad importante',
    'Incapacidad leve',
    'Incapacidad moderada',
    'Incapacidad moderadamente grave',
    'Incapacidad grave',
    'Muerte',
  ];

  RankinResult classify(int score) {
    assert(score >= 0 && score <= 6);
    return RankinResult(
      score: score,
      title: _titles[score],
      independence: _independence(score),
      severity: _severity(score),
    );
  }

  String _independence(int score) {
    if (score <= 2) return 'Independiente';
    if (score <= 4) return 'Semidependiente';
    return 'Dependiente';
  }

  Severity _severity(int score) {
    if (score <= 2) {
      return Severity(label: _titles[score], level: SeverityLevel.mild);
    }
    if (score <= 4) {
      return Severity(label: _titles[score], level: SeverityLevel.moderate);
    }
    return Severity(label: _titles[score], level: SeverityLevel.severe);
  }
}
