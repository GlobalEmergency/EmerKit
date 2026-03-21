import 'package:flutter_test/flutter_test.dart';
import 'package:navaja_suiza_sanitaria/features/lund_browder/domain/lund_browder_calculator.dart';
import 'package:navaja_suiza_sanitaria/features/lund_browder/domain/lund_browder_data.dart';
import 'package:navaja_suiza_sanitaria/shared/domain/entities/severity.dart';

void main() {
  group('LundBrowderCalculator', () {
    test('no burns gives 0% SCQ', () {
      final burns = List.filled(LundBrowderData.zoneNames.length, 0);
      final result = LundBrowderCalculator.calculate(
        burnDegrees: burns,
        ageGroupIndex: 5, // Adult
      );
      expect(result.totalScq, 0.0);
      expect(result.severity.label, 'Sin quemaduras');
    });

    test('head burned in adult gives 7%', () {
      final burns = List.filled(LundBrowderData.zoneNames.length, 0);
      burns[0] = 1; // Cabeza = index 0
      final result = LundBrowderCalculator.calculate(
        burnDegrees: burns,
        ageGroupIndex: 5, // Adult: head = 7%
      );
      expect(result.totalScq, 7.0);
      expect(result.severity.level, SeverityLevel.mild);
    });

    test('head burned in infant (<1yr) gives 19%', () {
      final burns = List.filled(LundBrowderData.zoneNames.length, 0);
      burns[0] = 2; // Cabeza, grado 2
      final result = LundBrowderCalculator.calculate(
        burnDegrees: burns,
        ageGroupIndex: 0, // <1 ano: head = 19%
      );
      expect(result.totalScq, 19.0);
      expect(result.severity.level, SeverityLevel.moderate);
    });

    test('all zones burned in adult gives 100%', () {
      final burns = List.filled(LundBrowderData.zoneNames.length, 1);
      final result = LundBrowderCalculator.calculate(
        burnDegrees: burns,
        ageGroupIndex: 5, // Adult
      );
      expect(result.totalScq, 100.0);
      expect(result.severity.level, SeverityLevel.severe);
    });

    test('SCQ < 15% classified as menor', () {
      final burns = List.filled(LundBrowderData.zoneNames.length, 0);
      burns[0] = 1; // Head adult = 7%
      final result = LundBrowderCalculator.calculate(
        burnDegrees: burns,
        ageGroupIndex: 5,
      );
      expect(result.totalScq, lessThan(15));
      expect(result.severity.label, 'Quemadura menor');
    });

    test('SCQ 15-30% classified as moderada', () {
      final burns = List.filled(LundBrowderData.zoneNames.length, 0);
      // Tronco anterior (13%) + Cuello (2%) = 15%
      burns[1] = 1; // Cuello
      burns[2] = 1; // Tronco anterior
      final result = LundBrowderCalculator.calculate(
        burnDegrees: burns,
        ageGroupIndex: 5,
      );
      expect(result.totalScq, 15.0);
      expect(result.severity.level, SeverityLevel.moderate);
    });

    test('SCQ >= 30% classified as gran quemado', () {
      final burns = List.filled(LundBrowderData.zoneNames.length, 0);
      // Tronco anterior (13%) + Tronco posterior (13%) + Head (7%) = 33%
      burns[0] = 1; // Cabeza
      burns[2] = 1; // Tronco anterior
      burns[3] = 1; // Tronco posterior
      final result = LundBrowderCalculator.calculate(
        burnDegrees: burns,
        ageGroupIndex: 5,
      );
      expect(result.totalScq, greaterThanOrEqualTo(30));
      expect(result.severity.level, SeverityLevel.severe);
    });
  });
}
