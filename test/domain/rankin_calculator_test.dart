import 'package:flutter_test/flutter_test.dart';
import 'package:emerkit/shared/domain/entities/severity.dart';
import 'package:emerkit/features/rankin/domain/rankin_calculator.dart';

void main() {
  const calculator = RankinCalculator();

  group('Paciente asintomatico (mRS 0)', () {
    test('score 0 es independiente', () {
      final r = calculator.classify(0);
      expect(r.score, 0);
      expect(r.title, 'Asintomatico');
      expect(r.independence, 'Independiente');
      expect(r.severity.level, SeverityLevel.mild);
    });
  });

  group('Paciente con incapacidad leve (mRS 1-2)', () {
    test('score 1 es independiente', () {
      final r = calculator.classify(1);
      expect(r.independence, 'Independiente');
      expect(r.severity.level, SeverityLevel.mild);
    });

    test('score 2 es limite superior de independencia', () {
      final r = calculator.classify(2);
      expect(r.title, 'Incapacidad leve');
      expect(r.independence, 'Independiente');
      expect(r.severity.level, SeverityLevel.mild);
    });
  });

  group('Paciente con incapacidad moderada (mRS 3-4)', () {
    test('score 3 es semidependiente', () {
      final r = calculator.classify(3);
      expect(r.title, 'Incapacidad moderada');
      expect(r.independence, 'Semidependiente');
      expect(r.severity.level, SeverityLevel.moderate);
    });

    test('score 4 es semidependiente', () {
      final r = calculator.classify(4);
      expect(r.title, 'Incapacidad moderadamente grave');
      expect(r.independence, 'Semidependiente');
      expect(r.severity.level, SeverityLevel.moderate);
    });
  });

  group('Paciente con incapacidad grave (mRS 5-6)', () {
    test('score 5 es dependiente', () {
      final r = calculator.classify(5);
      expect(r.title, 'Incapacidad grave');
      expect(r.independence, 'Dependiente');
      expect(r.severity.level, SeverityLevel.severe);
    });

    test('score 6 es muerte / dependiente', () {
      final r = calculator.classify(6);
      expect(r.title, 'Muerte');
      expect(r.independence, 'Dependiente');
      expect(r.severity.level, SeverityLevel.severe);
    });
  });
}
