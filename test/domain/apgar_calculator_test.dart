import 'package:flutter_test/flutter_test.dart';
import 'package:emerkit/shared/domain/entities/severity.dart';
import 'package:emerkit/features/apgar/domain/apgar_calculator.dart';

void main() {
  const calculator = ApgarCalculator();

  group('Recien nacido sano (puntuacion maxima)', () {
    test('Apgar 10 es Normal', () {
      final r = calculator.calculate(
        appearance: 2,
        pulse: 2,
        grimace: 2,
        activity: 2,
        respiration: 2,
      );
      expect(r.total, 10);
      expect(r.severity.label, 'Normal');
      expect(r.severity.level, SeverityLevel.mild);
    });
  });

  group('Depresion severa (puntuacion minima)', () {
    test('Apgar 0 es Depresion severa', () {
      final r = calculator.calculate(
        appearance: 0,
        pulse: 0,
        grimace: 0,
        activity: 0,
        respiration: 0,
      );
      expect(r.total, 0);
      expect(r.severity.label, 'Depresion severa');
      expect(r.severity.level, SeverityLevel.severe);
    });
  });

  group('Frontera severa/moderada (Apgar 3-4)', () {
    test('Apgar 3 es Depresion severa', () {
      final r = calculator.calculate(
        appearance: 0,
        pulse: 1,
        grimace: 1,
        activity: 0,
        respiration: 1,
      );
      expect(r.total, 3);
      expect(r.severity.label, 'Depresion severa');
      expect(r.severity.level, SeverityLevel.severe);
    });

    test('Apgar 4 es Depresion moderada', () {
      final r = calculator.calculate(
        appearance: 1,
        pulse: 1,
        grimace: 1,
        activity: 0,
        respiration: 1,
      );
      expect(r.total, 4);
      expect(r.severity.label, 'Depresion moderada');
      expect(r.severity.level, SeverityLevel.moderate);
    });
  });

  group('Frontera moderada/normal (Apgar 6-7)', () {
    test('Apgar 6 es Depresion moderada', () {
      final r = calculator.calculate(
        appearance: 1,
        pulse: 2,
        grimace: 1,
        activity: 1,
        respiration: 1,
      );
      expect(r.total, 6);
      expect(r.severity.label, 'Depresion moderada');
      expect(r.severity.level, SeverityLevel.moderate);
    });

    test('Apgar 7 es Normal', () {
      final r = calculator.calculate(
        appearance: 1,
        pulse: 2,
        grimace: 2,
        activity: 1,
        respiration: 1,
      );
      expect(r.total, 7);
      expect(r.severity.label, 'Normal');
      expect(r.severity.level, SeverityLevel.mild);
    });
  });

  group('Caso mixto tipico (acrocianosis con buena respuesta)', () {
    test('Neonato con acrocianosis y respuesta parcial', () {
      final r = calculator.calculate(
        appearance: 1,
        pulse: 2,
        grimace: 1,
        activity: 1,
        respiration: 1,
      );
      expect(r.appearance, 1);
      expect(r.pulse, 2);
      expect(r.grimace, 1);
      expect(r.activity, 1);
      expect(r.respiration, 1);
      expect(r.total, 6);
    });
  });
}
