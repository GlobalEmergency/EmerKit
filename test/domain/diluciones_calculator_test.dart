import 'package:flutter_test/flutter_test.dart';
import 'package:emerkit/features/diluciones/domain/diluciones_calculator.dart';

void main() {
  const calculator = DilutionCalculator();

  group('Dosis directa (extraer mL del vial)', () {
    test('Adrenalina 1mg/1mL, necesito 0.3 mg → extraer 0.3 mL', () {
      final r = calculator.calculateDose(
        drugAmountMg: 1,
        drugVolumeMl: 1,
        desiredDoseMg: 0.3,
      );
      expect(r.drugVolumeMl, closeTo(0.3, 0.001));
      expect(r.totalDoseMg, closeTo(0.3, 0.001));
      expect(r.diluentVolumeMl, 0);
      expect(r.vialsNeeded, 1);
    });

    test('Morfina 10mg/1mL, necesito 5 mg → extraer 0.5 mL', () {
      final r = calculator.calculateDose(
        drugAmountMg: 10,
        drugVolumeMl: 1,
        desiredDoseMg: 5,
      );
      expect(r.drugVolumeMl, closeTo(0.5, 0.001));
      expect(r.vialsNeeded, 1);
    });

    test('Necesito mas de un vial genera warning', () {
      // Vial 1mg/1mL, necesito 3mg → 3 viales
      final r = calculator.calculateDose(
        drugAmountMg: 1,
        drugVolumeMl: 1,
        desiredDoseMg: 3,
      );
      expect(r.drugVolumeMl, closeTo(3.0, 0.001));
      expect(r.vialsNeeded, 3);
      expect(r.warning, isNotNull);
    });

    test('Dosis cero devuelve resultado vacio', () {
      final r = calculator.calculateDose(
        drugAmountMg: 1,
        drugVolumeMl: 1,
        desiredDoseMg: 0,
      );
      expect(r.isEmpty, isTrue);
    });
  });

  group('Dilucion simple (C1 x V1 = C2 x V2)', () {
    test('Adrenalina 1mg/1mL diluida a 10 mL con concentracion 0.1 mg/mL', () {
      final r = calculator.calculateSimple(
        drugAmountMg: 1,
        drugVolumeMl: 1,
        finalVolumeMl: 10,
        desiredConcentrationMgMl: 0.1,
      );
      expect(r.drugVolumeMl, closeTo(1.0, 0.001));
      expect(r.diluentVolumeMl, closeTo(9.0, 0.001));
      expect(r.finalVolumeMl, 10.0);
      expect(r.finalConcentrationMgMl, closeTo(0.1, 0.001));
      expect(r.vialsNeeded, 1);
      expect(r.warning, isNull);
    });

    test('Dopamina 200mg/5mL en 250 mL sin concentracion deseada', () {
      final r = calculator.calculateSimple(
        drugAmountMg: 200,
        drugVolumeMl: 5,
        finalVolumeMl: 250,
      );
      // Usa vial completo: 5 mL, diluent = 245 mL
      expect(r.drugVolumeMl, closeTo(5.0, 0.001));
      expect(r.diluentVolumeMl, closeTo(245.0, 0.001));
      // Conc = (200/5 * 5) / 250 = 0.8 mg/mL
      expect(r.finalConcentrationMgMl, closeTo(0.8, 0.001));
    });

    test('Amiodarona 150mg/3mL a 0.6 mg/mL en 100 mL', () {
      // C1 = 50 mg/mL, V1 = (0.6 * 100) / 50 = 1.2 mL
      final r = calculator.calculateSimple(
        drugAmountMg: 150,
        drugVolumeMl: 3,
        finalVolumeMl: 100,
        desiredConcentrationMgMl: 0.6,
      );
      expect(r.drugVolumeMl, closeTo(1.2, 0.001));
      expect(r.diluentVolumeMl, closeTo(98.8, 0.001));
      expect(r.vialsNeeded, 1);
    });

    test('Inputs cero devuelven resultado vacio', () {
      expect(
        calculator
            .calculateSimple(
              drugAmountMg: 0,
              drugVolumeMl: 1,
              finalVolumeMl: 10,
            )
            .isEmpty,
        isTrue,
      );
      expect(
        calculator
            .calculateSimple(
              drugAmountMg: 1,
              drugVolumeMl: 0,
              finalVolumeMl: 10,
            )
            .isEmpty,
        isTrue,
      );
      expect(
        calculator
            .calculateSimple(
              drugAmountMg: 1,
              drugVolumeMl: 1,
              finalVolumeMl: 0,
            )
            .isEmpty,
        isTrue,
      );
    });

    test('Inputs negativos devuelven resultado vacio', () {
      final r = calculator.calculateSimple(
        drugAmountMg: -5,
        drugVolumeMl: 1,
        finalVolumeMl: 10,
      );
      expect(r.isEmpty, isTrue);
    });

    test('Volumen farmaco mayor que volumen final genera warning', () {
      // C1=1mg/mL, C2=2mg/mL, V2=5 → V1=10 > V2=5
      final r = calculator.calculateSimple(
        drugAmountMg: 1,
        drugVolumeMl: 1,
        finalVolumeMl: 5,
        desiredConcentrationMgMl: 2,
      );
      expect(r.drugVolumeMl, closeTo(10.0, 0.001));
      expect(r.warning, isNotNull);
      expect(r.warning, contains('supera'));
    });

    test('Necesidad de multiples viales genera warning', () {
      // Vial de 1mL, necesita 3mL → 3 viales
      // C1=1mg/mL, desea 0.3mg/mL en 10mL → V1 = 3mL
      final r = calculator.calculateSimple(
        drugAmountMg: 1,
        drugVolumeMl: 1,
        finalVolumeMl: 10,
        desiredConcentrationMgMl: 0.3,
      );
      expect(r.drugVolumeMl, closeTo(3.0, 0.001));
      expect(r.vialsNeeded, 3);
      expect(r.warning, isNotNull);
      expect(r.warning, contains('viales'));
    });
  });

  group('Dilucion por peso (dosificacion pediatrica/adulta)', () {
    test('Dosis unica: 10 kg, 0.01 mg/kg adrenalina 1mg/1mL en 10 mL', () {
      final r = calculator.calculateByWeight(
        drugAmountMg: 1,
        drugVolumeMl: 1,
        finalVolumeMl: 10,
        weightKg: 10,
        doseMgPerKg: 0.01,
      );
      // totalDose = 10 * 0.01 = 0.1 mg
      // V1 = 0.1 / 1 = 0.1 mL
      expect(r.totalDoseMg, closeTo(0.1, 0.001));
      expect(r.drugVolumeMl, closeTo(0.1, 0.001));
      expect(r.diluentVolumeMl, closeTo(9.9, 0.001));
      expect(r.infusionRateMlH, isNull);
    });

    test('Perfusion: Dopamina 5 mcg/kg/min, 70 kg, 200mg/5mL, 250 mL, 24h', () {
      final r = calculator.calculateByWeight(
        drugAmountMg: 200,
        drugVolumeMl: 5,
        finalVolumeMl: 250,
        weightKg: 70,
        doseMcgPerKgPerMin: 5,
        infusionHours: 24,
      );
      // totalDose = (5/1000) * 70 * 60 * 24 = 504 mg
      expect(r.totalDoseMg, closeTo(504, 0.1));
      // V1 = 504 / (200/5) = 504 / 40 = 12.6 mL
      expect(r.drugVolumeMl, closeTo(12.6, 0.1));
      // rate = 250/24 ≈ 10.42 mL/h
      expect(r.infusionRateMlH, closeTo(10.42, 0.1));
      // Needs ceil(12.6/5) = 3 vials
      expect(r.vialsNeeded, 3);
    });

    test('Pediatrico: 5 kg, 0.1 mg/kg, morfina 10mg/1mL en 10 mL', () {
      final r = calculator.calculateByWeight(
        drugAmountMg: 10,
        drugVolumeMl: 1,
        finalVolumeMl: 10,
        weightKg: 5,
        doseMgPerKg: 0.1,
      );
      // totalDose = 5 * 0.1 = 0.5 mg
      // V1 = 0.5 / 10 = 0.05 mL
      expect(r.totalDoseMg, closeTo(0.5, 0.001));
      expect(r.drugVolumeMl, closeTo(0.05, 0.001));
    });

    test('Peso cero devuelve resultado vacio', () {
      final r = calculator.calculateByWeight(
        drugAmountMg: 1,
        drugVolumeMl: 1,
        finalVolumeMl: 10,
        weightKg: 0,
        doseMgPerKg: 0.01,
      );
      expect(r.isEmpty, isTrue);
    });

    test('Sin dosis ni ritmo devuelve resultado vacio', () {
      final r = calculator.calculateByWeight(
        drugAmountMg: 1,
        drugVolumeMl: 1,
        finalVolumeMl: 10,
        weightKg: 70,
      );
      expect(r.isEmpty, isTrue);
    });

    test(
        'Perfusion con horas cero devuelve resultado de dosis unica si hay '
        'doseMgPerKg', () {
      final r = calculator.calculateByWeight(
        drugAmountMg: 1,
        drugVolumeMl: 1,
        finalVolumeMl: 10,
        weightKg: 70,
        doseMgPerKg: 0.01,
        doseMcgPerKgPerMin: 5,
        infusionHours: 0,
      );
      // infusionHours=0, so continuous branch skipped, falls to single dose
      expect(r.totalDoseMg, closeTo(0.7, 0.001));
      expect(r.infusionRateMlH, isNull);
    });
  });
}
