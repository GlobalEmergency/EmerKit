import 'package:flutter_test/flutter_test.dart';
import 'package:navaja_suiza_sanitaria/shared/domain/entities/severity.dart';
import 'package:navaja_suiza_sanitaria/features/tep/domain/tep_calculator.dart';

void main() {
  const calculator = TepCalculator();

  group('Paciente estable (todos normales)', () {
    test('3 lados normales = ESTABLE', () {
      final r = calculator.calculate(
        appearance: true,
        breathing: true,
        circulation: true,
      );
      expect(r.diagnosis, 'ESTABLE');
      expect(r.abnormalCount, 0);
      expect(r.severity.level, SeverityLevel.mild);
    });
  });

  group('Un lado alterado', () {
    test('solo apariencia anormal = DISFUNCION DEL SNC', () {
      final r = calculator.calculate(
        appearance: false,
        breathing: true,
        circulation: true,
      );
      expect(r.diagnosis, 'DISFUNCION DEL SNC');
      expect(r.abnormalCount, 1);
      expect(r.severity.level, SeverityLevel.moderate);
    });

    test('solo respiracion anormal = DIFICULTAD RESPIRATORIA', () {
      final r = calculator.calculate(
        appearance: true,
        breathing: false,
        circulation: true,
      );
      expect(r.diagnosis, 'DIFICULTAD RESPIRATORIA');
      expect(r.abnormalCount, 1);
    });

    test('solo circulacion anormal = SHOCK COMPENSADO', () {
      final r = calculator.calculate(
        appearance: true,
        breathing: true,
        circulation: false,
      );
      expect(r.diagnosis, 'SHOCK COMPENSADO');
      expect(r.abnormalCount, 1);
    });
  });

  group('Dos lados alterados', () {
    test('apariencia + respiracion = FALLO RESPIRATORIO', () {
      final r = calculator.calculate(
        appearance: false,
        breathing: false,
        circulation: true,
      );
      expect(r.diagnosis, 'FALLO RESPIRATORIO');
      expect(r.abnormalCount, 2);
      expect(r.severity.level, SeverityLevel.severe);
    });

    test('apariencia + circulacion = SHOCK DESCOMPENSADO', () {
      final r = calculator.calculate(
        appearance: false,
        breathing: true,
        circulation: false,
      );
      expect(r.diagnosis, 'SHOCK DESCOMPENSADO');
      expect(r.abnormalCount, 2);
    });

    test('respiracion + circulacion = FALLO CARDIORRESPIRATORIO', () {
      final r = calculator.calculate(
        appearance: true,
        breathing: false,
        circulation: false,
      );
      expect(r.diagnosis, 'FALLO CARDIORRESPIRATORIO');
      expect(r.abnormalCount, 2);
    });
  });

  group('Parada cardiorrespiratoria (todos anormales)', () {
    test('3 lados anormales = PARADA CARDIORRESPIRATORIA', () {
      final r = calculator.calculate(
        appearance: false,
        breathing: false,
        circulation: false,
      );
      expect(r.diagnosis, 'PARADA CARDIORRESPIRATORIA');
      expect(r.abnormalCount, 3);
      expect(r.severity.level, SeverityLevel.severe);
    });
  });
}
