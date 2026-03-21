import 'package:flutter_test/flutter_test.dart';
import 'package:navaja_suiza_sanitaria/shared/domain/entities/severity.dart';
import 'package:navaja_suiza_sanitaria/features/glasgow/domain/glasgow_calculator.dart';

void main() {
  const calculator = GlasgowCalculator();

  group('Paciente con maxima puntuacion (normal)', () {
    test('GCS 15 es Leve', () {
      final r = calculator.calculate(eye: 4, verbal: 5, motor: 6);
      expect(r.total, 15);
      expect(r.severity.label, 'Leve');
      expect(r.severity.level, SeverityLevel.mild);
    });
  });

  group('Paciente con minima puntuacion (coma profundo)', () {
    test('GCS 3 es Grave', () {
      final r = calculator.calculate(eye: 1, verbal: 1, motor: 1);
      expect(r.total, 3);
      expect(r.severity.label, 'Grave');
      expect(r.severity.level, SeverityLevel.severe);
    });
  });

  group('Limite de intubacion (GCS 8)', () {
    test('GCS 8 es Grave - considerar IOT', () {
      final r = calculator.calculate(eye: 2, verbal: 2, motor: 4);
      expect(r.total, 8);
      expect(r.severity.label, 'Grave');
      expect(r.severity.level, SeverityLevel.severe);
    });
  });

  group('Limite Grave/Moderado (GCS 9)', () {
    test('GCS 9 es Moderado', () {
      final r = calculator.calculate(eye: 2, verbal: 3, motor: 4);
      expect(r.total, 9);
      expect(r.severity.label, 'Moderado');
      expect(r.severity.level, SeverityLevel.moderate);
    });
  });

  group('Limite Moderado/Leve (GCS 12-13)', () {
    test('GCS 12 es Moderado', () {
      final r = calculator.calculate(eye: 3, verbal: 4, motor: 5);
      expect(r.total, 12);
      expect(r.severity.label, 'Moderado');
      expect(r.severity.level, SeverityLevel.moderate);
    });

    test('GCS 13 es Leve', () {
      final r = calculator.calculate(eye: 4, verbal: 4, motor: 5);
      expect(r.total, 13);
      expect(r.severity.label, 'Leve');
      expect(r.severity.level, SeverityLevel.mild);
    });
  });

  group('Descomposicion de puntuaciones parciales', () {
    test('devuelve las puntuaciones individuales correctas', () {
      final r = calculator.calculate(eye: 3, verbal: 2, motor: 5);
      expect(r.eye, 3);
      expect(r.verbal, 2);
      expect(r.motor, 5);
      expect(r.total, 10);
    });
  });
}
