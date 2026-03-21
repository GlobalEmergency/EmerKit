import 'package:navaja_suiza_sanitaria/shared/domain/entities/severity.dart';

class O2Result {
  final double autonomyMinutes;
  final double usablePressure;
  final Severity severity;
  final String formatted;

  const O2Result({
    required this.autonomyMinutes,
    required this.usablePressure,
    required this.severity,
    required this.formatted,
  });
}

class O2Calculator {
  static const double securityReserve = 20; // bar

  /// Calcula la autonomia de una botella de O2.
  ///
  /// [bottleLiters] volumen de la botella en litros.
  /// [pressure] presion del manometro en bar.
  /// [flowRate] caudal en L/min.
  static O2Result calculate({
    required double bottleLiters,
    required double pressure,
    required double flowRate,
  }) {
    final usable = (pressure - securityReserve).clamp(0.0, double.infinity);

    double minutes;
    if (flowRate <= 0 || usable <= 0) {
      minutes = 0;
    } else {
      minutes = (bottleLiters * usable) / flowRate;
    }

    final severity = _classify(minutes);
    final formatted = _format(minutes);

    return O2Result(
      autonomyMinutes: minutes,
      usablePressure: usable,
      severity: severity,
      formatted: formatted,
    );
  }

  static Severity _classify(double minutes) {
    if (minutes < 10) {
      return const Severity(
        label: 'Autonomia critica',
        level: SeverityLevel.severe,
      );
    }
    if (minutes <= 30) {
      return const Severity(
        label: 'Autonomia limitada',
        level: SeverityLevel.moderate,
      );
    }
    return const Severity(
      label: 'Autonomia adecuada',
      level: SeverityLevel.mild,
    );
  }

  static String _format(double minutes) {
    if (minutes.isInfinite || minutes.isNaN) return '--:--';
    final totalMin = minutes.round();
    final hours = totalMin ~/ 60;
    final mins = totalMin % 60;
    return '${hours}h ${mins.toString().padLeft(2, '0')}min';
  }
}
