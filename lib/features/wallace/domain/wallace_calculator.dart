import 'package:emerkit/shared/domain/entities/severity.dart';

import 'wallace_data.dart';

class WallaceResult {
  final double totalScq;
  final Severity severity;
  final bool hasSpecialZone;
  final double? parkland24h;
  final double? parklandFirst8hRate;
  final double? parklandNext16hRate;
  final double? ruleOf10Rate;
  final double? urineTargetMin;
  final double? urineTargetMax;

  const WallaceResult({
    required this.totalScq,
    required this.severity,
    required this.hasSpecialZone,
    this.parkland24h,
    this.parklandFirst8hRate,
    this.parklandNext16hRate,
    this.ruleOf10Rate,
    this.urineTargetMin,
    this.urineTargetMax,
  });
}

class WallaceCalculator {
  const WallaceCalculator();

  WallaceResult calculate({
    required List<bool> burnedZones,
    required int ageGroupIndex,
    double? weightKg,
  }) {
    const percentages = WallaceData.zonePercentages;
    double total = 0;
    bool specialZone = false;

    for (int i = 0; i < percentages.length && i < burnedZones.length; i++) {
      if (burnedZones[i]) {
        total += percentages[i][ageGroupIndex];
        if (WallaceData.specialZoneIndices.contains(i)) {
          specialZone = true;
        }
      }
    }

    final isPediatric = ageGroupIndex > 0;
    final severity = _classify(total, isPediatric);
    final needsFluids = _needsFluidResuscitation(total, isPediatric);

    double? parkland24h;
    double? first8hRate;
    double? next16hRate;
    double? ruleOf10Rate;
    double? urineMin;
    double? urineMax;

    if (weightKg != null && weightKg > 0 && needsFluids) {
      parkland24h = 4 * weightKg * total / 100;
      first8hRate = parkland24h / 8;
      next16hRate = parkland24h / 16;

      final roundedScq = ((total / 10).round()) * 10;
      ruleOf10Rate = roundedScq.toDouble();
      if (weightKg > 80) {
        ruleOf10Rate = ruleOf10Rate + (((weightKg - 80) / 10).floor() * 100);
      }

      if (isPediatric) {
        urineMin = weightKg * 1.0;
        urineMax = weightKg * 1.5;
      } else {
        urineMin = weightKg * 0.5;
        urineMax = weightKg * 1.0;
      }
    }

    return WallaceResult(
      totalScq: total,
      severity: severity,
      hasSpecialZone: specialZone,
      parkland24h: parkland24h,
      parklandFirst8hRate: first8hRate,
      parklandNext16hRate: next16hRate,
      ruleOf10Rate: ruleOf10Rate,
      urineTargetMin: urineMin,
      urineTargetMax: urineMax,
    );
  }

  bool _needsFluidResuscitation(double scq, bool isPediatric) {
    if (isPediatric) return scq >= 10;
    return scq >= 20;
  }

  Severity _classify(double scq, bool isPediatric) {
    if (scq == 0) {
      return const Severity(
        label: 'Sin quemaduras',
        level: SeverityLevel.mild,
      );
    }

    if (isPediatric) {
      if (scq < 10) {
        return const Severity(
          label: 'Quemadura menor',
          level: SeverityLevel.mild,
        );
      }
      if (scq < 20) {
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
