import 'package:emerkit/shared/domain/entities/severity.dart';

class TepResult {
  final String diagnosis;
  final Severity severity;
  final int abnormalCount;

  const TepResult({
    required this.diagnosis,
    required this.severity,
    required this.abnormalCount,
  });
}

class TepCalculator {
  const TepCalculator();

  TepResult calculate({
    required bool? appearance,
    required bool? breathing,
    required bool? circulation,
  }) {
    final abnormal =
        [appearance, breathing, circulation].where((v) => v == false).length;

    final diagnosis = _diagnosis(
      appearance: appearance,
      breathing: breathing,
      circulation: circulation,
      abnormalCount: abnormal,
    );

    return TepResult(
      diagnosis: diagnosis,
      severity: _severity(abnormal),
      abnormalCount: abnormal,
    );
  }

  String _diagnosis({
    required bool? appearance,
    required bool? breathing,
    required bool? circulation,
    required int abnormalCount,
  }) {
    if (abnormalCount == 0) return 'ESTABLE';
    if (abnormalCount == 3) return 'PARADA CARDIORRESPIRATORIA';

    if (abnormalCount == 1) {
      if (appearance == false) return 'DISFUNCION DEL SNC';
      if (breathing == false) return 'DIFICULTAD RESPIRATORIA';
      if (circulation == false) return 'SHOCK COMPENSADO';
    }

    // Two abnormal
    if (appearance == false && breathing == false) return 'FALLO RESPIRATORIO';
    if (appearance == false && circulation == false) {
      return 'SHOCK DESCOMPENSADO';
    }
    if (breathing == false && circulation == false) {
      return 'FALLO CARDIORRESPIRATORIO';
    }

    return 'ESTABLE';
  }

  Severity _severity(int abnormalCount) {
    if (abnormalCount == 0) {
      return const Severity(label: 'Estable', level: SeverityLevel.mild);
    }
    if (abnormalCount == 1) {
      return const Severity(label: 'Alterado', level: SeverityLevel.moderate);
    }
    return const Severity(label: 'Grave', level: SeverityLevel.severe);
  }
}
