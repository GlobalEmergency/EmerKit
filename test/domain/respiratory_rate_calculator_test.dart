import 'package:flutter_test/flutter_test.dart';
import 'package:emerkit/features/respiratory_rate/domain/respiratory_rate_calculator.dart';
import 'package:emerkit/shared/domain/entities/severity.dart';

void main() {
  // ---------------------------------------------------------------
  // Simple tap-based calculator (backwards compatibility)
  // ---------------------------------------------------------------
  group('RespiratoryRateCalculator (tap-based)', () {
    test('2 taps 4 seconds apart gives 15 rpm (eupnea)', () {
      final base = DateTime(2024, 1, 1, 12, 0, 0);
      final taps = [
        base,
        base.add(const Duration(seconds: 4)),
      ];
      final result = RespiratoryRateCalculator.calculateRpm(taps);
      expect(result, isNotNull);
      expect(result!.rpm, 15);
      expect(result.severity.label, 'Eupnea');
    });

    test('needs at least 2 taps', () {
      final result = RespiratoryRateCalculator.calculateRpm([DateTime.now()]);
      expect(result, isNull);
    });

    test('empty list returns null', () {
      final result = RespiratoryRateCalculator.calculateRpm([]);
      expect(result, isNull);
    });

    test('3 taps 3 seconds apart gives 20 rpm (eupnea)', () {
      final base = DateTime(2024, 1, 1, 12, 0, 0);
      final taps = [
        base,
        base.add(const Duration(seconds: 3)),
        base.add(const Duration(seconds: 6)),
      ];
      final result = RespiratoryRateCalculator.calculateRpm(taps);
      expect(result, isNotNull);
      expect(result!.rpm, 20);
      expect(result.severity.label, 'Eupnea');
    });

    test('rpm < 12 classified as bradipnea (moderate)', () {
      final base = DateTime(2024, 1, 1, 12, 0, 0);
      final taps = [
        base,
        base.add(const Duration(seconds: 10)),
      ];
      final result = RespiratoryRateCalculator.calculateRpm(taps);
      expect(result!.rpm, 6);
      expect(result.severity.level, SeverityLevel.moderate);
      expect(result.severity.label, 'Bradipnea');
    });

    test('rpm 12-20 classified as eupnea (mild)', () {
      final base = DateTime(2024, 1, 1, 12, 0, 0);
      final taps = [
        base,
        base.add(const Duration(seconds: 4)),
      ];
      final result = RespiratoryRateCalculator.calculateRpm(taps);
      expect(result!.rpm, 15);
      expect(result.severity.level, SeverityLevel.mild);
      expect(result.severity.label, 'Eupnea');
    });

    test('rpm 12 is eupnea (lower boundary)', () {
      final result = RespiratoryRateCalculator.classify(12);
      expect(result.level, SeverityLevel.mild);
      expect(result.label, 'Eupnea');
    });

    test('rpm 20 is eupnea (upper boundary)', () {
      final result = RespiratoryRateCalculator.classify(20);
      expect(result.level, SeverityLevel.mild);
      expect(result.label, 'Eupnea');
    });

    test('rpm 21-29 classified as taquipnea (moderate)', () {
      final base = DateTime(2024, 1, 1, 12, 0, 0);
      final taps = [
        base,
        base.add(const Duration(milliseconds: 2400)),
      ];
      final result = RespiratoryRateCalculator.calculateRpm(taps);
      expect(result!.rpm, 25);
      expect(result.severity.level, SeverityLevel.moderate);
      expect(result.severity.label, 'Taquipnea');
    });

    test('rpm >= 30 classified as taquipnea severa (severe)', () {
      final base = DateTime(2024, 1, 1, 12, 0, 0);
      final taps = [
        base,
        base.add(const Duration(milliseconds: 1500)),
      ];
      final result = RespiratoryRateCalculator.calculateRpm(taps);
      expect(result!.rpm, 40);
      expect(result.severity.level, SeverityLevel.severe);
      expect(result.severity.label, 'Taquipnea severa');
    });

    test('rpm 11 is bradipnea (boundary)', () {
      final result = RespiratoryRateCalculator.classify(11);
      expect(result.level, SeverityLevel.moderate);
      expect(result.label, 'Bradipnea');
    });

    test('rpm 30 is taquipnea severa (boundary)', () {
      final result = RespiratoryRateCalculator.classify(30);
      expect(result.level, SeverityLevel.severe);
      expect(result.label, 'Taquipnea severa');
    });

    test('rpm 29 is taquipnea (upper boundary)', () {
      final result = RespiratoryRateCalculator.classify(29);
      expect(result.level, SeverityLevel.moderate);
      expect(result.label, 'Taquipnea');
    });
  });

  // ---------------------------------------------------------------
  // Full breath analysis (press & hold)
  // ---------------------------------------------------------------

  /// Helper: genera lista de respiraciones regulares
  List<Breath> regularBreaths({
    required int count,
    required int inspMs,
    required int expMs,
  }) {
    final base = DateTime(2024, 1, 1, 12, 0, 0);
    final breaths = <Breath>[];
    var cursor = base;
    for (var i = 0; i < count; i++) {
      breaths.add(Breath(
        inspirationStart: cursor,
        inspirationEnd: cursor.add(Duration(milliseconds: inspMs)),
      ));
      cursor = cursor.add(Duration(milliseconds: inspMs + expMs));
    }
    return breaths;
  }

  group('analyzeBreathing - necesita minimo 2 respiraciones', () {
    test('0 breaths returns null', () {
      expect(RespiratoryRateCalculator.analyzeBreathing([]), isNull);
    });

    test('1 breath returns null', () {
      final base = DateTime(2024, 1, 1, 12, 0, 0);
      final b = [
        Breath(
          inspirationStart: base,
          inspirationEnd: base.add(const Duration(seconds: 1)),
        )
      ];
      expect(RespiratoryRateCalculator.analyzeBreathing(b), isNull);
    });
  });

  group('Eupnea - respiracion normal ritmica', () {
    test('15 rpm, I:E ~1:2, regular = eupnea', () {
      // 4s ciclo = 15 rpm, inspMs=1333 expMs=2667 → I:E = 2667/1333 = 2.0
      final breaths = regularBreaths(
        count: 5,
        inspMs: 1333,
        expMs: 2667,
      );
      final analysis = RespiratoryRateCalculator.analyzeBreathing(breaths);
      expect(analysis, isNotNull);
      expect(analysis!.rpm, 15);
      expect(analysis.pattern.type, RespiratoryPatternType.eupnea);
      expect(analysis.pattern.description, 'Respiracion normal, ritmica');
      expect(analysis.ieRatio, closeTo(2.0, 0.2));
      expect(analysis.regularityCV, lessThan(20));
      expect(analysis.severity.level, SeverityLevel.mild);
    });
  });

  group('Bradipnea - respiracion lenta', () {
    test('8 rpm, regular = bradipnea', () {
      // 7.5s ciclo = 8 rpm, inspMs=2500 expMs=5000
      final breaths = regularBreaths(
        count: 4,
        inspMs: 2500,
        expMs: 5000,
      );
      final analysis = RespiratoryRateCalculator.analyzeBreathing(breaths);
      expect(analysis, isNotNull);
      expect(analysis!.rpm, 8);
      expect(analysis.pattern.type, RespiratoryPatternType.bradypnea);
      expect(analysis.pattern.label, 'Bradipnea');
      expect(analysis.severity.level, SeverityLevel.moderate);
    });
  });

  group('Taquipnea - respiracion rapida superficial', () {
    test('25 rpm, inspiracion corta, regular = taquipnea', () {
      // 2.4s ciclo = 25 rpm, inspMs=600 expMs=1800 (I:E 1:3, superficial)
      final breaths = regularBreaths(
        count: 5,
        inspMs: 600,
        expMs: 1800,
      );
      final analysis = RespiratoryRateCalculator.analyzeBreathing(breaths);
      expect(analysis, isNotNull);
      expect(analysis!.rpm, 25);
      expect(analysis.pattern.type, RespiratoryPatternType.tachypnea);
      expect(analysis.pattern.label, 'Taquipnea');
      expect(analysis.severity.level, SeverityLevel.moderate);
    });
  });

  group('Kussmaul - respiracion rapida y profunda', () {
    test('25 rpm, inspiracion larga (>40% ciclo), regular = Kussmaul', () {
      // 2.4s ciclo = 25 rpm, inspMs=1100 expMs=1300
      // inspFraction = 1100/2400 = 0.458 > 0.40
      final breaths = regularBreaths(
        count: 5,
        inspMs: 1100,
        expMs: 1300,
      );
      final analysis = RespiratoryRateCalculator.analyzeBreathing(breaths);
      expect(analysis, isNotNull);
      expect(analysis!.rpm, 25);
      expect(analysis.pattern.type, RespiratoryPatternType.kussmaul);
      expect(analysis.pattern.label, 'Kussmaul');
      expect(analysis.pattern.description, contains('acidosis metabolica'));
      expect(analysis.severity.level, SeverityLevel.moderate);
    });
  });

  group('Apneustica - inspiracion prolongada', () {
    test('I:E invertido (I > E) = apneustica', () {
      // inspMs=3000 expMs=1500 → I:E = 1500/3000 = 0.5 (invertido)
      final breaths = regularBreaths(
        count: 4,
        inspMs: 3000,
        expMs: 1500,
      );
      final analysis = RespiratoryRateCalculator.analyzeBreathing(breaths);
      expect(analysis, isNotNull);
      expect(analysis!.pattern.type, RespiratoryPatternType.apneustic);
      expect(analysis.pattern.label, 'Apneustica');
      expect(analysis.ieRatio, lessThan(1.0));
      expect(analysis.severity.level, SeverityLevel.severe);
    });
  });

  group('Biot - respiracion irregular e impredecible', () {
    test('CV > 50% = Biot', () {
      final base = DateTime(2024, 1, 1, 12, 0, 0);
      // Ciclos muy irregulares: 2s, 8s, 1.5s, 6s, 3s
      final breaths = [
        Breath(
          inspirationStart: base,
          inspirationEnd: base.add(const Duration(milliseconds: 500)),
        ),
        Breath(
          inspirationStart: base.add(const Duration(milliseconds: 2000)),
          inspirationEnd: base.add(const Duration(milliseconds: 2800)),
        ),
        Breath(
          inspirationStart: base.add(const Duration(milliseconds: 10000)),
          inspirationEnd: base.add(const Duration(milliseconds: 10300)),
        ),
        Breath(
          inspirationStart: base.add(const Duration(milliseconds: 11500)),
          inspirationEnd: base.add(const Duration(milliseconds: 12000)),
        ),
        Breath(
          inspirationStart: base.add(const Duration(milliseconds: 17500)),
          inspirationEnd: base.add(const Duration(milliseconds: 18200)),
        ),
      ];
      final analysis = RespiratoryRateCalculator.analyzeBreathing(breaths);
      expect(analysis, isNotNull);
      expect(analysis!.pattern.type, RespiratoryPatternType.biot);
      expect(analysis.pattern.label, 'Biot');
      expect(analysis.regularityCV, greaterThan(50));
      expect(analysis.severity.level, SeverityLevel.severe);
    });
  });

  group('Cheyne-Stokes - ciclos crescendo-decrescendo', () {
    test('>= 6 respiraciones con patron creciente/decreciente', () {
      final base = DateTime(2024, 1, 1, 12, 0, 0);
      // Ciclos crecientes y luego decrecientes:
      // 2s, 3s, 4s, 5s, 4s, 3s, 2s
      final cycleDurations = [2000, 3000, 4000, 5000, 4000, 3000, 2000];
      final breaths = <Breath>[];
      var cursor = base;
      for (final cycleMs in cycleDurations) {
        final inspMs = (cycleMs * 0.33).round();
        final expMs = cycleMs - inspMs;
        breaths.add(Breath(
          inspirationStart: cursor,
          inspirationEnd: cursor.add(Duration(milliseconds: inspMs)),
        ));
        cursor = cursor.add(Duration(milliseconds: inspMs + expMs));
      }

      final analysis = RespiratoryRateCalculator.analyzeBreathing(breaths);
      expect(analysis, isNotNull);
      expect(analysis!.pattern.type, RespiratoryPatternType.cheyneStokes);
      expect(analysis.pattern.label, 'Cheyne-Stokes');
      expect(analysis.severity.level, SeverityLevel.severe);
    });
  });

  group('RespiratoryAnalysis formatting', () {
    test('ieRatioFormatted shows 1:X.X format', () {
      final analysis = RespiratoryAnalysis(
        rpm: 15,
        ieRatio: 2.3,
        regularityCV: 10,
        pattern: RespiratoryPattern.patterns[RespiratoryPatternType.eupnea]!,
        severity: const Severity(label: 'Normal', level: SeverityLevel.mild),
      );
      expect(analysis.ieRatioFormatted, '1:2.3');
    });

    test('regularityLabel returns correct label', () {
      expect(
        RespiratoryAnalysis(
          rpm: 15,
          ieRatio: 2.0,
          regularityCV: 10,
          pattern: RespiratoryPattern.patterns[RespiratoryPatternType.eupnea]!,
          severity: const Severity(label: 'Normal', level: SeverityLevel.mild),
        ).regularityLabel,
        'Regular',
      );
      expect(
        RespiratoryAnalysis(
          rpm: 15,
          ieRatio: 2.0,
          regularityCV: 35,
          pattern: RespiratoryPattern.patterns[RespiratoryPatternType.eupnea]!,
          severity: const Severity(label: 'Normal', level: SeverityLevel.mild),
        ).regularityLabel,
        'Irregular',
      );
      expect(
        RespiratoryAnalysis(
          rpm: 15,
          ieRatio: 2.0,
          regularityCV: 60,
          pattern: RespiratoryPattern.patterns[RespiratoryPatternType.eupnea]!,
          severity: const Severity(label: 'Normal', level: SeverityLevel.mild),
        ).regularityLabel,
        'Muy irregular',
      );
    });
  });
}
