import 'package:flutter_test/flutter_test.dart';
import 'package:emerkit/shared/domain/entities/severity.dart';
import 'package:emerkit/features/shock_index/domain/shock_index_calculator.dart';

void main() {
  const calculator = ShockIndexCalculator();

  group('Indice de Shock normal (SI < 0.7)', () {
    test('FC 60 / TAS 120 = SI 0.50, Normal', () {
      final r =
          calculator.calculate(heartRate: 60, systolicBP: 120, diastolicBP: 80);
      expect(r.shockIndex, closeTo(0.50, 0.01));
      expect(r.severity.label, 'Normal');
      expect(r.severity.level, SeverityLevel.mild);
    });

    test('FC 70 / TAS 130 = SI 0.54, Normal', () {
      final r =
          calculator.calculate(heartRate: 70, systolicBP: 130, diastolicBP: 85);
      expect(r.shockIndex, closeTo(0.54, 0.01));
      expect(r.severity.level, SeverityLevel.mild);
    });
  });

  group('Indice de Shock normal-alto (SI 0.7-0.99)', () {
    test('FC 80 / TAS 100 = SI 0.80, Normal-alto', () {
      final r =
          calculator.calculate(heartRate: 80, systolicBP: 100, diastolicBP: 70);
      expect(r.shockIndex, closeTo(0.80, 0.01));
      expect(r.severity.label, 'Normal-alto');
      expect(r.severity.level, SeverityLevel.moderate);
    });
  });

  group('Indice de Shock elevado (SI >= 1.0)', () {
    test('FC 120 / TAS 90 = SI 1.33, Muy elevado', () {
      final r =
          calculator.calculate(heartRate: 120, systolicBP: 90, diastolicBP: 60);
      expect(r.shockIndex, closeTo(1.33, 0.01));
      expect(r.severity.label, 'Muy elevado');
      expect(r.severity.level, SeverityLevel.severe);
    });

    test('FC 100 / TAS 90 = SI 1.11, Elevado', () {
      final r =
          calculator.calculate(heartRate: 100, systolicBP: 90, diastolicBP: 60);
      expect(r.shockIndex, closeTo(1.11, 0.01));
      expect(r.severity.label, 'Elevado');
      expect(r.severity.level, SeverityLevel.severe);
    });
  });

  group('Tension Arterial Media (TAM)', () {
    test('TAS 120, TAD 80 -> TAM = 93.3', () {
      final r =
          calculator.calculate(heartRate: 80, systolicBP: 120, diastolicBP: 80);
      expect(r.tam, closeTo(93.3, 0.1));
    });

    test('TAS 90, TAD 60 -> TAM = 70.0', () {
      final r =
          calculator.calculate(heartRate: 100, systolicBP: 90, diastolicBP: 60);
      expect(r.tam, closeTo(70.0, 0.1));
    });
  });

  group('Indice de Shock Modificado (MSI)', () {
    test('FC 80, TAM 93.3 -> MSI = 0.86, Normal', () {
      final r =
          calculator.calculate(heartRate: 80, systolicBP: 120, diastolicBP: 80);
      expect(r.modifiedShockIndex, closeTo(0.86, 0.01));
      expect(r.msiSeverity.label, 'Normal');
      expect(r.msiSeverity.level, SeverityLevel.mild);
    });

    test('FC 140, TAM 70 -> MSI = 2.0, Muy elevado', () {
      final r =
          calculator.calculate(heartRate: 140, systolicBP: 90, diastolicBP: 60);
      expect(r.modifiedShockIndex, closeTo(2.0, 0.01));
      expect(r.msiSeverity.label, 'Muy elevado');
      expect(r.msiSeverity.level, SeverityLevel.severe);
    });
  });

  group('SIPA pediatrico', () {
    test('Nino 2 anos, SI 1.30 >= umbral 1.22 -> SIPA elevado', () {
      final r = calculator.calculate(
        heartRate: 130,
        systolicBP: 100,
        diastolicBP: 60,
        isPediatric: true,
        ageYears: 2,
      );
      expect(r.shockIndex, closeTo(1.30, 0.01));
      expect(r.sipaThreshold, 1.22);
      expect(r.severity.label, 'SIPA elevado');
      expect(r.severity.level, SeverityLevel.severe);
    });

    test('Nino 5 anos, SI 1.0 < umbral 1.20 -> Normal', () {
      final r = calculator.calculate(
        heartRate: 100,
        systolicBP: 100,
        diastolicBP: 65,
        isPediatric: true,
        ageYears: 5,
      );
      expect(r.shockIndex, closeTo(1.0, 0.01));
      expect(r.sipaThreshold, 1.20);
      expect(r.severity.label, 'Normal');
      expect(r.severity.level, SeverityLevel.mild);
    });

    test('Nino 10 anos, SI 1.10 >= umbral 1.0 -> SIPA elevado', () {
      final r = calculator.calculate(
        heartRate: 110,
        systolicBP: 100,
        diastolicBP: 65,
        isPediatric: true,
        ageYears: 10,
      );
      expect(r.shockIndex, closeTo(1.10, 0.01));
      expect(r.sipaThreshold, 1.0);
      expect(r.severity.label, 'SIPA elevado');
      expect(r.severity.level, SeverityLevel.severe);
    });

    test('Adolescente 15 anos, SI 0.80 < umbral 0.90 -> Normal', () {
      final r = calculator.calculate(
        heartRate: 80,
        systolicBP: 100,
        diastolicBP: 65,
        isPediatric: true,
        ageYears: 15,
      );
      expect(r.shockIndex, closeTo(0.80, 0.01));
      expect(r.sipaThreshold, 0.9);
      expect(r.severity.label, 'Normal');
      expect(r.severity.level, SeverityLevel.mild);
    });
  });
}
