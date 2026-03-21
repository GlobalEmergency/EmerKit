import 'package:flutter_test/flutter_test.dart';
import 'package:navaja_suiza_sanitaria/features/ictus/domain/cincinnati_calculator.dart';

void main() {
  const calculator = CincinnatiCalculator();

  group('CincinnatiCalculator', () {
    test('all normal = score 0, no stroke suspected', () {
      final result = calculator.calculate(
        facialDroop: false,
        armDrift: false,
        speech: false,
      );
      expect(result.score, 0);
      expect(result.suspectedStroke, isFalse);
    });

    test('facial droop only = score 1, stroke suspected', () {
      final result = calculator.calculate(
        facialDroop: true,
        armDrift: false,
        speech: false,
      );
      expect(result.score, 1);
      expect(result.suspectedStroke, isTrue);
    });

    test('all abnormal = score 3, stroke suspected', () {
      final result = calculator.calculate(
        facialDroop: true,
        armDrift: true,
        speech: true,
      );
      expect(result.score, 3);
      expect(result.suspectedStroke, isTrue);
    });

    test('arm drift only = score 1, stroke suspected', () {
      final result = calculator.calculate(
        facialDroop: false,
        armDrift: true,
        speech: false,
      );
      expect(result.score, 1);
      expect(result.suspectedStroke, isTrue);
    });

    test('speech only = score 1, stroke suspected', () {
      final result = calculator.calculate(
        facialDroop: false,
        armDrift: false,
        speech: true,
      );
      expect(result.score, 1);
      expect(result.suspectedStroke, isTrue);
    });
  });
}
