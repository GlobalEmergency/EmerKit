import 'package:flutter_test/flutter_test.dart';
import 'package:navaja_suiza_sanitaria/shared/domain/temperature_classifier.dart';
import 'package:navaja_suiza_sanitaria/shared/domain/entities/severity.dart';

void main() {
  group('TemperatureClassifier - Hypothermia', () {
    test('36.5 C classified as NORMAL', () {
      final result = TemperatureClassifier.classifyHypothermia(36.5);
      expect(result.label, 'NORMAL');
      expect(result.severity.level, SeverityLevel.mild);
    });

    test('35.0 C classified as NORMAL (boundary)', () {
      final result = TemperatureClassifier.classifyHypothermia(35.0);
      expect(result.label, 'NORMAL');
    });

    test('33.0 C classified as LEVE', () {
      final result = TemperatureClassifier.classifyHypothermia(33.0);
      expect(result.label, 'LEVE');
      expect(result.severity.level, SeverityLevel.moderate);
      expect(result.symptoms, isNotEmpty);
      expect(result.treatment, isNotEmpty);
    });

    test('30.0 C classified as MODERADA', () {
      final result = TemperatureClassifier.classifyHypothermia(30.0);
      expect(result.label, 'MODERADA');
      expect(result.severity.level, SeverityLevel.severe);
    });

    test('27.0 C classified as GRAVE', () {
      final result = TemperatureClassifier.classifyHypothermia(27.0);
      expect(result.label, 'GRAVE');
      expect(result.severity.level, SeverityLevel.severe);
    });

    test('28.0 C classified as MODERADA (boundary)', () {
      final result = TemperatureClassifier.classifyHypothermia(28.0);
      expect(result.label, 'MODERADA');
    });

    test('32.0 C classified as LEVE (boundary)', () {
      final result = TemperatureClassifier.classifyHypothermia(32.0);
      expect(result.label, 'LEVE');
    });
  });

  group('TemperatureClassifier - Hyperthermia', () {
    test('37.0 C classified as NORMAL', () {
      final result = TemperatureClassifier.classifyHyperthermia(37.0);
      expect(result.label, 'NORMAL');
      expect(result.severity.level, SeverityLevel.mild);
    });

    test('37.5 C classified as FEBRICULA (boundary)', () {
      final result = TemperatureClassifier.classifyHyperthermia(37.5);
      expect(result.label, 'FEBRICULA');
      expect(result.severity.level, SeverityLevel.moderate);
    });

    test('39.0 C classified as AGOTAMIENTO POR CALOR', () {
      final result = TemperatureClassifier.classifyHyperthermia(39.0);
      expect(result.label, 'AGOTAMIENTO POR CALOR');
      expect(result.severity.level, SeverityLevel.moderate);
    });

    test('38.0 C classified as AGOTAMIENTO POR CALOR (boundary)', () {
      final result = TemperatureClassifier.classifyHyperthermia(38.0);
      expect(result.label, 'AGOTAMIENTO POR CALOR');
    });

    test('41.0 C classified as GOLPE DE CALOR', () {
      final result = TemperatureClassifier.classifyHyperthermia(41.0);
      expect(result.label, 'GOLPE DE CALOR');
      expect(result.severity.level, SeverityLevel.severe);
      expect(result.symptoms, isNotEmpty);
      expect(result.treatment, isNotEmpty);
    });

    test('40.0 C classified as AGOTAMIENTO (boundary, not >40)', () {
      final result = TemperatureClassifier.classifyHyperthermia(40.0);
      expect(result.label, 'AGOTAMIENTO POR CALOR');
    });

    test('40.5 C classified as GOLPE DE CALOR', () {
      final result = TemperatureClassifier.classifyHyperthermia(40.5);
      expect(result.label, 'GOLPE DE CALOR');
    });
  });
}
