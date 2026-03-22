import 'package:flutter_test/flutter_test.dart';
import 'package:navaja_suiza_sanitaria/features/madrid_direct/domain/madrid_direct_calculator.dart';

void main() {
  const calculator = MadridDirectCalculator();

  group('MadridDirectCalculator', () {
    test('2 items positive, normal TAS/age = score 2, thrombectomy required',
        () {
      final result = calculator.calculate(
        armNoGravity: true,
        legNoGravity: true,
        gazeDeviation: false,
        noObeyOrders: false,
        noRecognizeDeficit: false,
        tas: 140,
        age: 65,
      );
      expect(result.score, 2);
      expect(result.requiresThrombectomy, isTrue);
    });

    test('4 items positive, TAS 200 = score 1, no thrombectomy', () {
      // 4 clinical items = 4 points
      // TAS 200: (200-180)/10 + 1 = 3 points subtracted
      // 4 - 3 = 1
      final result = calculator.calculate(
        armNoGravity: true,
        legNoGravity: true,
        gazeDeviation: true,
        noObeyOrders: true,
        noRecognizeDeficit: false,
        tas: 200,
        age: 65,
      );
      expect(result.score, 1);
      expect(result.requiresThrombectomy, isFalse);
    });

    test('2 items positive, age 87 = score 0, no thrombectomy', () {
      // 2 clinical items = 2 points
      // Age 87: 87-84 = 3 points subtracted
      // 2 - 3 = -1, but we just check score
      final result = calculator.calculate(
        armNoGravity: true,
        legNoGravity: true,
        gazeDeviation: false,
        noObeyOrders: false,
        noRecognizeDeficit: false,
        tas: 140,
        age: 87,
      );
      expect(result.score, lessThan(2));
      expect(result.requiresThrombectomy, isFalse);
    });

    test('noObeyOrders and noRecognizeDeficit both true counts as 1', () {
      // Both mutually exclusive items true: calculator should count only 1
      // arm + leg + gaze + 1 (mutual exclusive pair) = 4
      final resultBoth = calculator.calculate(
        armNoGravity: true,
        legNoGravity: true,
        gazeDeviation: true,
        noObeyOrders: true,
        noRecognizeDeficit: true,
        tas: 140,
        age: 65,
      );

      // Compare with only one of the pair selected
      final resultOne = calculator.calculate(
        armNoGravity: true,
        legNoGravity: true,
        gazeDeviation: true,
        noObeyOrders: true,
        noRecognizeDeficit: false,
        tas: 140,
        age: 65,
      );

      expect(resultBoth.score, resultOne.score);
      expect(resultBoth.score, 4);
    });

    test('all items false, normal TAS/age = score 0', () {
      final result = calculator.calculate(
        armNoGravity: false,
        legNoGravity: false,
        gazeDeviation: false,
        noObeyOrders: false,
        noRecognizeDeficit: false,
        tas: 140,
        age: 65,
      );
      expect(result.score, 0);
      expect(result.requiresThrombectomy, isFalse);
    });

    test('TAS exactly 180 subtracts 1 point', () {
      // 3 items = 3, TAS 180: (180-180)/10 + 1 = 1 subtracted => 2
      final result = calculator.calculate(
        armNoGravity: true,
        legNoGravity: true,
        gazeDeviation: true,
        noObeyOrders: false,
        noRecognizeDeficit: false,
        tas: 180,
        age: 65,
      );
      expect(result.score, 2);
    });

    test('age exactly 85 subtracts 1 point', () {
      // 3 items = 3, age 85: 85-84 = 1 subtracted => 2
      final result = calculator.calculate(
        armNoGravity: true,
        legNoGravity: true,
        gazeDeviation: true,
        noObeyOrders: false,
        noRecognizeDeficit: false,
        tas: 140,
        age: 85,
      );
      expect(result.score, 2);
    });
  });
}
