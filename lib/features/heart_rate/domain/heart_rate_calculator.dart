import 'package:navaja_suiza_sanitaria/shared/domain/entities/severity.dart';

class HeartRateResult {
  final int bpm;
  final Severity severity;

  const HeartRateResult({
    required this.bpm,
    required this.severity,
  });
}

class HeartRateCalculator {
  /// Calcula los latidos por minuto a partir de una lista de timestamps.
  ///
  /// Requiere al menos 2 taps. Devuelve null si no hay suficientes datos.
  static HeartRateResult? calculateBpm(List<DateTime> taps) {
    if (taps.length < 2) return null;

    final totalMs = taps.last.difference(taps.first).inMilliseconds;
    if (totalMs == 0) return null;

    final bpm = ((taps.length - 1) * 60000 / totalMs).round();
    return HeartRateResult(bpm: bpm, severity: _classify(bpm));
  }

  static Severity _classify(int bpm) {
    if (bpm < 60) {
      return const Severity(
        label: 'Bradicardia',
        level: SeverityLevel.moderate,
      );
    }
    if (bpm <= 100) {
      return const Severity(
        label: 'Normal',
        level: SeverityLevel.mild,
      );
    }
    return const Severity(
      label: 'Taquicardia',
      level: SeverityLevel.moderate,
    );
  }
}
