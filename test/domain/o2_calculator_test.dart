import 'package:flutter_test/flutter_test.dart';
import 'package:navaja_suiza_sanitaria/features/o2_calculator/domain/o2_calculator.dart';
import 'package:navaja_suiza_sanitaria/shared/domain/entities/severity.dart';

void main() {
  group('O2Calculator', () {
    test('5L bottle at 200 bar with 10 L/min gives 90 minutes', () {
      final result = O2Calculator.calculate(
        bottleLiters: 5,
        pressure: 200,
        flowRate: 10,
      );
      // usablePressure = 200 - 20 = 180
      // autonomy = (5 * 180) / 10 = 90 min
      expect(result.autonomyMinutes, 90.0);
      expect(result.usablePressure, 180.0);
    });

    test('pressure at security reserve (20 bar) gives 0 minutes', () {
      final result = O2Calculator.calculate(
        bottleLiters: 5,
        pressure: 20,
        flowRate: 10,
      );
      expect(result.autonomyMinutes, 0.0);
      expect(result.usablePressure, 0.0);
    });

    test('autonomy < 10 min classified as severe', () {
      // 1L, 25 bar, 10 L/min -> usable=5, autonomy = 1*5/10 = 0.5 min
      final result = O2Calculator.calculate(
        bottleLiters: 1,
        pressure: 25,
        flowRate: 10,
      );
      expect(result.autonomyMinutes, 0.5);
      expect(result.severity.level, SeverityLevel.severe);
    });

    test('autonomy 10-30 min classified as moderate', () {
      // 5L, 60 bar, 10 L/min -> usable=40, autonomy = 5*40/10 = 20 min
      final result = O2Calculator.calculate(
        bottleLiters: 5,
        pressure: 60,
        flowRate: 10,
      );
      expect(result.autonomyMinutes, 20.0);
      expect(result.severity.level, SeverityLevel.moderate);
    });

    test('autonomy > 30 min classified as mild', () {
      final result = O2Calculator.calculate(
        bottleLiters: 5,
        pressure: 200,
        flowRate: 10,
      );
      expect(result.autonomyMinutes, 90.0);
      expect(result.severity.level, SeverityLevel.mild);
    });

    test('zero flow rate gives 0 minutes', () {
      final result = O2Calculator.calculate(
        bottleLiters: 5,
        pressure: 200,
        flowRate: 0,
      );
      expect(result.autonomyMinutes, 0.0);
    });

    test('formatted output is correct', () {
      final result = O2Calculator.calculate(
        bottleLiters: 5,
        pressure: 200,
        flowRate: 10,
      );
      expect(result.formatted, '1h 30min');
    });
  });
}
