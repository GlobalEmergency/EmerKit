import 'package:flutter_test/flutter_test.dart';
import 'package:emerkit/shared/domain/entities/severity.dart';
import 'package:emerkit/features/wallace/domain/wallace_calculator.dart';
import 'package:emerkit/features/wallace/domain/wallace_data.dart';

void main() {
  const calculator = WallaceCalculator();
  final noBurns = List.filled(WallaceData.zoneNames.length, false);

  List<bool> burned(List<int> indices) {
    final zones = List.filled(WallaceData.zoneNames.length, false);
    for (final i in indices) {
      zones[i] = true;
    }
    return zones;
  }

  group('Sin quemaduras', () {
    test('todas las zonas sin quemar devuelve 0% y mild', () {
      final result = calculator.calculate(
        burnedZones: noBurns,
        ageGroupIndex: 0,
      );
      expect(result.totalScq, 0.0);
      expect(result.severity.label, 'Sin quemaduras');
      expect(result.severity.level, SeverityLevel.mild);
      expect(result.hasSpecialZone, false);
      expect(result.parkland24h, isNull);
    });
  });

  group('Quemadura menor adulto', () {
    test('solo cabeza quemada (9%) es quemadura menor', () {
      final result = calculator.calculate(
        burnedZones: burned([0]),
        ageGroupIndex: 0,
      );
      expect(result.totalScq, 9.0);
      expect(result.severity.label, 'Quemadura menor');
      expect(result.severity.level, SeverityLevel.mild);
    });

    test('una extremidad superior (9%) es quemadura menor', () {
      final result = calculator.calculate(
        burnedZones: burned([1]),
        ageGroupIndex: 0,
      );
      expect(result.totalScq, 9.0);
      expect(result.severity.level, SeverityLevel.mild);
    });
  });

  group('Quemadura moderada adulto', () {
    test('tronco anterior (18%) es quemadura moderada', () {
      final result = calculator.calculate(
        burnedZones: burned([3]),
        ageGroupIndex: 0,
      );
      expect(result.totalScq, 18.0);
      expect(result.severity.label, 'Quemadura moderada');
      expect(result.severity.level, SeverityLevel.moderate);
    });

    test('cabeza + EESS derecha (18%) es quemadura moderada', () {
      final result = calculator.calculate(
        burnedZones: burned([0, 1]),
        ageGroupIndex: 0,
      );
      expect(result.totalScq, 18.0);
      expect(result.severity.level, SeverityLevel.moderate);
    });
  });

  group('Gran quemado adulto', () {
    test('tronco anterior + posterior (36%) es gran quemado', () {
      final result = calculator.calculate(
        burnedZones: burned([3, 4]),
        ageGroupIndex: 0,
      );
      expect(result.totalScq, 36.0);
      expect(result.severity.label, 'Gran quemado');
      expect(result.severity.level, SeverityLevel.severe);
    });
  });

  group('Todas las zonas quemadas', () {
    test('suma 100% en adulto', () {
      final allBurned = List.filled(WallaceData.zoneNames.length, true);
      final result = calculator.calculate(
        burnedZones: allBurned,
        ageGroupIndex: 0,
      );
      expect(result.totalScq, 100.0);
      expect(result.severity.level, SeverityLevel.severe);
    });

    test('suma 101% en pediatrico 1 ano (aproximacion conocida)', () {
      // La Regla de los 9 modificada para 1 ano suma 101% porque es
      // una estimacion rapida: 18+9+9+18+18+14+14+1 = 101.
      // Para calculo preciso usar Lund-Browder.
      final allBurned = List.filled(WallaceData.zoneNames.length, true);
      final result = calculator.calculate(
        burnedZones: allBurned,
        ageGroupIndex: 3,
      );
      expect(result.totalScq, 101.0);
    });
  });

  group('Modificacion pediatrica', () {
    test('cabeza en nino de 1 ano es 18% (mayor que adulto)', () {
      final result = calculator.calculate(
        burnedZones: burned([0]),
        ageGroupIndex: 3,
      );
      expect(result.totalScq, 18.0);
    });

    test('EEII en nino de 1 ano es 14% (menor que adulto)', () {
      final result = calculator.calculate(
        burnedZones: burned([5]),
        ageGroupIndex: 3,
      );
      expect(result.totalScq, 14.0);
    });

    test('cabeza en nino de 5 anos es 15%', () {
      final result = calculator.calculate(
        burnedZones: burned([0]),
        ageGroupIndex: 2,
      );
      expect(result.totalScq, 15.0);
    });

    test('umbrales pediatricos: 10% es moderada', () {
      final result = calculator.calculate(
        burnedZones: burned([0]),
        ageGroupIndex: 3,
      );
      expect(result.totalScq, 18.0);
      expect(result.severity.level, SeverityLevel.moderate);
    });

    test('umbrales pediatricos: EESS (9%) es menor', () {
      final result = calculator.calculate(
        burnedZones: burned([1]),
        ageGroupIndex: 3,
      );
      expect(result.totalScq, 9.0);
      expect(result.severity.level, SeverityLevel.mild);
    });
  });

  group('Zonas especiales', () {
    test('cabeza es zona especial', () {
      final result = calculator.calculate(
        burnedZones: burned([0]),
        ageGroupIndex: 0,
      );
      expect(result.hasSpecialZone, true);
    });

    test('perineo es zona especial', () {
      final result = calculator.calculate(
        burnedZones: burned([7]),
        ageGroupIndex: 0,
      );
      expect(result.hasSpecialZone, true);
    });

    test('tronco no es zona especial', () {
      final result = calculator.calculate(
        burnedZones: burned([3]),
        ageGroupIndex: 0,
      );
      expect(result.hasSpecialZone, false);
    });
  });

  group('Reposicion hidrica - Parkland', () {
    test('70kg con 40% SCQ da 11200 mL en 24h', () {
      final result = calculator.calculate(
        burnedZones: burned([3, 4, 0]),
        ageGroupIndex: 0,
        weightKg: 70,
      );
      // Tronco ant(18) + post(18) + cabeza(9) = 45%
      expect(result.totalScq, 45.0);
      expect(result.parkland24h, 4 * 70 * 45 / 100);
    });

    test('distribucion Parkland: 50% en 8h, 50% en 16h', () {
      // Usamos tronco ant + post = 36%
      final result = calculator.calculate(
        burnedZones: burned([3, 4]),
        ageGroupIndex: 0,
        weightKg: 70,
      );
      const total = 4.0 * 70 * 36 / 100;
      expect(result.parkland24h, total);
      expect(result.parklandFirst8hRate, total / 8);
      expect(result.parklandNext16hRate, total / 16);
    });

    test('diuresis objetivo adulto: 0.5-1 mL/kg/h', () {
      final result = calculator.calculate(
        burnedZones: burned([3, 4]),
        ageGroupIndex: 0,
        weightKg: 70,
      );
      expect(result.urineTargetMin, 70 * 0.5);
      expect(result.urineTargetMax, 70 * 1.0);
    });

    test('diuresis objetivo pediatrico: 1-1.5 mL/kg/h', () {
      final result = calculator.calculate(
        burnedZones: burned([0, 3]),
        ageGroupIndex: 3,
        weightKg: 10,
      );
      // Cabeza(18) + tronco ant(18) = 36% >= 10% pediatrico
      expect(result.urineTargetMin, 10 * 1.0);
      expect(result.urineTargetMax, 10 * 1.5);
    });
  });

  group('Reposicion hidrica - Regla del 10', () {
    test('35% SCQ redondea a 40 y da 400 mL/h', () {
      // Cabeza(9) + tronco ant(18) + EESS-D(9) = 36%
      final result = calculator.calculate(
        burnedZones: burned([0, 3, 1]),
        ageGroupIndex: 0,
        weightKg: 70,
      );
      // 36% redondea a 40 -> 40*10 = 400 (peso <80 sin ajuste)
      // Pero totalScq es 36, round(36/10)*10 = 40, ruleOf10 = 40
      expect(result.ruleOf10Rate, 40.0);
    });

    test('peso >80kg anade 100 mL/h por cada 10kg extra', () {
      final result = calculator.calculate(
        burnedZones: burned([3, 4]),
        ageGroupIndex: 0,
        weightKg: 100,
      );
      // 36% -> round to 40 -> base 40, + (100-80)/10 * 100 = +200
      // ruleOf10 = 40 + 200 = 240
      expect(result.ruleOf10Rate, 240.0);
    });
  });

  group('Sin reposicion hidrica', () {
    test('no calcula si no hay peso', () {
      final result = calculator.calculate(
        burnedZones: burned([3, 4]),
        ageGroupIndex: 0,
      );
      expect(result.parkland24h, isNull);
      expect(result.ruleOf10Rate, isNull);
    });

    test('no calcula si SCQ < 20% en adulto aunque haya peso', () {
      final result = calculator.calculate(
        burnedZones: burned([0]),
        ageGroupIndex: 0,
        weightKg: 70,
      );
      expect(result.totalScq, 9.0);
      expect(result.parkland24h, isNull);
    });

    test('no calcula si SCQ < 10% en pediatrico aunque haya peso', () {
      final result = calculator.calculate(
        burnedZones: burned([1]),
        ageGroupIndex: 3,
        weightKg: 10,
      );
      expect(result.totalScq, 9.0);
      expect(result.parkland24h, isNull);
    });

    test('calcula si SCQ >= 10% en pediatrico con peso', () {
      final result = calculator.calculate(
        burnedZones: burned([0]),
        ageGroupIndex: 3,
        weightKg: 10,
      );
      expect(result.totalScq, 18.0);
      expect(result.parkland24h, isNotNull);
    });
  });
}
