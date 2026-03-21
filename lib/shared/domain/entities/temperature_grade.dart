import 'severity.dart';

/// Resultado de clasificación de temperatura, compartido entre hipotermia e hipertermia.
class TemperatureGrade {
  final String label;
  final Severity severity;
  final List<String> symptoms;
  final List<String> treatment;

  const TemperatureGrade({
    required this.label,
    required this.severity,
    required this.symptoms,
    required this.treatment,
  });
}
