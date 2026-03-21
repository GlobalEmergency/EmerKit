import 'package:flutter_test/flutter_test.dart';
import 'package:navaja_suiza_sanitaria/features/heart_rate/domain/heart_rate_calculator.dart';
import 'package:navaja_suiza_sanitaria/shared/domain/entities/severity.dart';

void main() {
  group('HeartRateCalculator', () {
    test('2 taps 1 second apart gives 60 bpm', () {
      final base = DateTime(2024, 1, 1, 12, 0, 0);
      final taps = [
        base,
        base.add(const Duration(seconds: 1)),
      ];
      final result = HeartRateCalculator.calculateBpm(taps);
      expect(result, isNotNull);
      expect(result!.bpm, 60);
    });

    test('needs at least 2 taps', () {
      final result = HeartRateCalculator.calculateBpm([DateTime.now()]);
      expect(result, isNull);
    });

    test('empty list returns null', () {
      final result = HeartRateCalculator.calculateBpm([]);
      expect(result, isNull);
    });

    test('3 taps 500ms apart gives 120 bpm', () {
      final base = DateTime(2024, 1, 1, 12, 0, 0);
      final taps = [
        base,
        base.add(const Duration(milliseconds: 500)),
        base.add(const Duration(milliseconds: 1000)),
      ];
      // (3-1) * 60000 / 1000 = 120
      final result = HeartRateCalculator.calculateBpm(taps);
      expect(result, isNotNull);
      expect(result!.bpm, 120);
    });

    test('bpm < 60 classified as bradicardia (moderate)', () {
      final base = DateTime(2024, 1, 1, 12, 0, 0);
      final taps = [
        base,
        base.add(const Duration(milliseconds: 1500)),
      ];
      // (2-1) * 60000 / 1500 = 40 bpm
      final result = HeartRateCalculator.calculateBpm(taps);
      expect(result!.bpm, 40);
      expect(result.severity.level, SeverityLevel.moderate);
      expect(result.severity.label, 'Bradicardia');
    });

    test('bpm 60-100 classified as normal (mild)', () {
      final base = DateTime(2024, 1, 1, 12, 0, 0);
      final taps = [
        base,
        base.add(const Duration(milliseconds: 750)),
      ];
      // (2-1) * 60000 / 750 = 80 bpm
      final result = HeartRateCalculator.calculateBpm(taps);
      expect(result!.bpm, 80);
      expect(result.severity.level, SeverityLevel.mild);
      expect(result.severity.label, 'Normal');
    });

    test('bpm > 100 classified as taquicardia (moderate)', () {
      final base = DateTime(2024, 1, 1, 12, 0, 0);
      final taps = [
        base,
        base.add(const Duration(milliseconds: 400)),
      ];
      // (2-1) * 60000 / 400 = 150 bpm
      final result = HeartRateCalculator.calculateBpm(taps);
      expect(result!.bpm, 150);
      expect(result.severity.level, SeverityLevel.moderate);
      expect(result.severity.label, 'Taquicardia');
    });
  });
}
