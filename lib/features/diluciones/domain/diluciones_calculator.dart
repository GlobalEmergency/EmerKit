import 'dart:math';

class DilutionResult {
  final double drugVolumeMl;
  final double diluentVolumeMl;
  final double finalVolumeMl;
  final double finalConcentrationMgMl;
  final double? totalDoseMg;
  final double? infusionRateMlH;
  final int vialsNeeded;
  final String? warning;

  const DilutionResult({
    required this.drugVolumeMl,
    required this.diluentVolumeMl,
    required this.finalVolumeMl,
    required this.finalConcentrationMgMl,
    this.totalDoseMg,
    this.infusionRateMlH,
    this.vialsNeeded = 1,
    this.warning,
  });

  const DilutionResult.empty()
      : drugVolumeMl = 0,
        diluentVolumeMl = 0,
        finalVolumeMl = 0,
        finalConcentrationMgMl = 0,
        totalDoseMg = null,
        infusionRateMlH = null,
        vialsNeeded = 0,
        warning = null;

  bool get isEmpty => finalVolumeMl == 0;
}

class DilutionCalculator {
  const DilutionCalculator();

  /// Direct dose: given a desired dose in mg, calculates how many mL
  /// to draw from the vial. No dilution involved.
  DilutionResult calculateDose({
    required double drugAmountMg,
    required double drugVolumeMl,
    required double desiredDoseMg,
  }) {
    if (drugAmountMg <= 0 || drugVolumeMl <= 0 || desiredDoseMg <= 0) {
      return const DilutionResult.empty();
    }

    final c1 = drugAmountMg / drugVolumeMl;
    final drugVol = desiredDoseMg / c1;
    final vials = (drugVol / drugVolumeMl).ceil();

    String? warning;
    if (vials > 1) {
      warning = 'Se necesitan $vials viales para obtener '
          '${_fmt(drugVol)} mL del farmaco.';
    }

    return DilutionResult(
      drugVolumeMl: drugVol,
      diluentVolumeMl: 0,
      finalVolumeMl: drugVol,
      finalConcentrationMgMl: c1,
      totalDoseMg: desiredDoseMg,
      vialsNeeded: vials,
      warning: warning,
    );
  }

  /// Standard dilution: C1×V1 = C2×V2
  ///
  /// Given the drug vial (drugAmountMg in drugVolumeMl) and a desired
  /// final volume, calculates how much drug to draw and how much
  /// diluent to add.
  ///
  /// If [desiredConcentrationMgMl] is provided, uses it to compute
  /// the drug volume needed. Otherwise, uses the full vial.
  DilutionResult calculateSimple({
    required double drugAmountMg,
    required double drugVolumeMl,
    required double finalVolumeMl,
    double? desiredConcentrationMgMl,
  }) {
    if (drugAmountMg <= 0 || drugVolumeMl <= 0 || finalVolumeMl <= 0) {
      return const DilutionResult.empty();
    }

    final c1 = drugAmountMg / drugVolumeMl;

    double drugVol;
    double finalConc;

    if (desiredConcentrationMgMl != null && desiredConcentrationMgMl > 0) {
      // C1 * V1 = C2 * V2  →  V1 = (C2 * V2) / C1
      drugVol = (desiredConcentrationMgMl * finalVolumeMl) / c1;
      finalConc = desiredConcentrationMgMl;
    } else {
      // Use full vial, calculate resulting concentration
      drugVol = drugVolumeMl;
      finalConc = (c1 * drugVol) / finalVolumeMl;
    }

    return _buildResult(
      drugVol: drugVol,
      finalVol: finalVolumeMl,
      finalConc: finalConc,
      vialVolumeMl: drugVolumeMl,
    );
  }

  /// Weight-based dosing followed by dilution.
  ///
  /// For single doses: totalDose = weightKg × doseMgPerKg
  /// For continuous infusion: totalDose = (doseMcgPerKgPerMin / 1000)
  ///   × weightKg × 60 × infusionHours
  DilutionResult calculateByWeight({
    required double drugAmountMg,
    required double drugVolumeMl,
    required double finalVolumeMl,
    required double weightKg,
    double? doseMgPerKg,
    double? doseMcgPerKgPerMin,
    double? infusionHours,
  }) {
    if (drugAmountMg <= 0 ||
        drugVolumeMl <= 0 ||
        finalVolumeMl <= 0 ||
        weightKg <= 0) {
      return const DilutionResult.empty();
    }

    final c1 = drugAmountMg / drugVolumeMl;
    double totalDose;
    double? rate;

    if (doseMcgPerKgPerMin != null &&
        doseMcgPerKgPerMin > 0 &&
        infusionHours != null &&
        infusionHours > 0) {
      // Continuous infusion
      totalDose = (doseMcgPerKgPerMin / 1000) * weightKg * 60 * infusionHours;
      rate = finalVolumeMl / infusionHours;
    } else if (doseMgPerKg != null && doseMgPerKg > 0) {
      // Single dose
      totalDose = weightKg * doseMgPerKg;
    } else {
      return const DilutionResult.empty();
    }

    // V1 = totalDose / C1
    final drugVol = totalDose / c1;
    final finalConc = totalDose / finalVolumeMl;

    return _buildResult(
      drugVol: drugVol,
      finalVol: finalVolumeMl,
      finalConc: finalConc,
      vialVolumeMl: drugVolumeMl,
      totalDose: totalDose,
      infusionRate: rate,
    );
  }

  DilutionResult _buildResult({
    required double drugVol,
    required double finalVol,
    required double finalConc,
    required double vialVolumeMl,
    double? totalDose,
    double? infusionRate,
  }) {
    final vials = (drugVol / vialVolumeMl).ceil();
    final diluent = finalVol - drugVol;

    String? warning;
    if (drugVol > finalVol) {
      warning = 'El volumen de farmaco (${_fmt(drugVol)} mL) supera el volumen '
          'final deseado (${_fmt(finalVol)} mL). Revise los valores.';
    } else if (vials > 1) {
      warning = 'Se necesitan $vials viales para obtener '
          '${_fmt(drugVol)} mL del farmaco.';
    }

    return DilutionResult(
      drugVolumeMl: drugVol,
      diluentVolumeMl: max(0, diluent),
      finalVolumeMl: finalVol,
      finalConcentrationMgMl: finalConc,
      totalDoseMg: totalDose,
      infusionRateMlH: infusionRate,
      vialsNeeded: vials,
      warning: warning,
    );
  }

  String _fmt(double v) => v.toStringAsFixed(2);
}
