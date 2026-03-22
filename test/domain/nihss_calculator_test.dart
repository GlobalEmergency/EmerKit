import 'package:flutter_test/flutter_test.dart';
import 'package:emerkit/shared/domain/entities/severity.dart';
import 'package:emerkit/features/nihss/domain/nihss_calculator.dart';

void main() {
  const calculator = NihssCalculator();

  group('Paciente sin deficit neurologico', () {
    test('NIHSS 0 es Sin deficit', () {
      final r = calculator.calculate(List.filled(15, 0));
      expect(r.total, 0);
      expect(r.severity.label, 'Sin deficit');
      expect(r.severity.level, SeverityLevel.mild);
    });
  });

  group('Deficit menor (1-4)', () {
    test('NIHSS 1 es Deficit menor', () {
      final scores = List.filled(15, 0)..[0] = 1;
      final r = calculator.calculate(scores);
      expect(r.total, 1);
      expect(r.severity.label, 'Deficit menor');
    });

    test('NIHSS 4 es Deficit menor (limite superior)', () {
      final scores = List.filled(15, 0)
        ..[0] = 1
        ..[1] = 1
        ..[2] = 1
        ..[3] = 1;
      final r = calculator.calculate(scores);
      expect(r.total, 4);
      expect(r.severity.label, 'Deficit menor');
      expect(r.severity.level, SeverityLevel.mild);
    });
  });

  group('Deficit moderado (5-15)', () {
    test('NIHSS 5 es Deficit moderado (limite inferior)', () {
      final scores = List.filled(15, 0)
        ..[0] = 2
        ..[1] = 1
        ..[2] = 1
        ..[3] = 1;
      final r = calculator.calculate(scores);
      expect(r.total, 5);
      expect(r.severity.label, 'Deficit moderado');
      expect(r.severity.level, SeverityLevel.moderate);
    });

    test('NIHSS 15 es Deficit moderado (limite superior)', () {
      final scores = List.filled(15, 1);
      final r = calculator.calculate(scores);
      expect(r.total, 15);
      expect(r.severity.label, 'Deficit moderado');
    });
  });

  group('Deficit moderado-grave (16-20)', () {
    test('NIHSS 16 es Deficit moderado-grave', () {
      final scores = List.filled(15, 0)
        ..[0] = 3
        ..[6] = 4
        ..[7] = 4
        ..[8] = 4
        ..[12] = 1;
      final r = calculator.calculate(scores);
      expect(r.total, 16);
      expect(r.severity.label, 'Deficit moderado-grave');
      expect(r.severity.level, SeverityLevel.severe);
    });
  });

  group('Deficit grave (21-42)', () {
    test('NIHSS 21 es Deficit grave (limite inferior)', () {
      final scores = List.filled(15, 0)
        ..[0] = 3
        ..[5] = 3
        ..[6] = 4
        ..[7] = 4
        ..[8] = 4
        ..[12] = 3;
      final r = calculator.calculate(scores);
      expect(r.total, 21);
      expect(r.severity.label, 'Deficit grave');
      expect(r.severity.level, SeverityLevel.severe);
    });

    test('NIHSS 42 es puntuacion maxima posible', () {
      // Max scores: 3,2,2,2,3,3,4,4,4,4,2,2,3,2,2 = 42
      final scores = [3, 2, 2, 2, 3, 3, 4, 4, 4, 4, 2, 2, 3, 2, 2];
      final r = calculator.calculate(scores);
      expect(r.total, 42);
      expect(r.severity.label, 'Deficit grave');
    });
  });
}
