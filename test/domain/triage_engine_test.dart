import 'package:flutter_test/flutter_test.dart';
import 'package:emerkit/features/triage/domain/triage_engine.dart';
import 'package:emerkit/features/triage/domain/triage_data.dart';

void main() {
  late TriageEngine engine;

  setUp(() {
    engine = const TriageEngine(nodes: TriageData.triageNodes);
  });

  group('TriageEngine - START triage', () {
    test('walks = YES -> GREEN', () {
      // walk? YES -> green
      final nodeId = engine.walkPath('walk', [true]);
      expect(engine.isResult(nodeId), isTrue);
      final result = engine.getResult(nodeId)!;
      expect(result.color, TriageColor.green);
      expect(result.label, 'VERDE');
    });

    test('no walk, no breathe, no breathe after airway = BLACK', () {
      // walk? NO -> breathe? NO -> open_airway? NO -> black
      final nodeId = engine.walkPath('walk', [false, false, false]);
      expect(engine.isResult(nodeId), isTrue);
      final result = engine.getResult(nodeId)!;
      expect(result.color, TriageColor.black);
      expect(result.label, 'NEGRO');
    });

    test('no walk, breathes, RR<30, perfusion OK, obeys orders = YELLOW', () {
      // walk? NO -> breathe? YES -> resp_rate<30? YES -> perfusion? YES -> mental? YES -> yellow
      final nodeId = engine.walkPath('walk', [false, true, true, true, true]);
      expect(engine.isResult(nodeId), isTrue);
      final result = engine.getResult(nodeId)!;
      expect(result.color, TriageColor.yellow);
      expect(result.label, 'AMARILLO');
    });

    test('no walk, breathes, RR>=30 = RED', () {
      // walk? NO -> breathe? YES -> resp_rate<30? NO -> red_immediate
      final nodeId = engine.walkPath('walk', [false, true, false]);
      expect(engine.isResult(nodeId), isTrue);
      final result = engine.getResult(nodeId)!;
      expect(result.color, TriageColor.red);
      expect(result.label, 'ROJO');
    });

    test('no walk, no breathe, breathes after airway = RED', () {
      // walk? NO -> breathe? NO -> open_airway? YES -> red_immediate
      final nodeId = engine.walkPath('walk', [false, false, true]);
      expect(engine.isResult(nodeId), isTrue);
      final result = engine.getResult(nodeId)!;
      expect(result.color, TriageColor.red);
    });

    test('no walk, breathes, RR<30, no perfusion = RED', () {
      // walk? NO -> breathe? YES -> resp_rate<30? YES -> perfusion? NO -> red_immediate
      final nodeId = engine.walkPath('walk', [false, true, true, false]);
      expect(engine.isResult(nodeId), isTrue);
      final result = engine.getResult(nodeId)!;
      expect(result.color, TriageColor.red);
    });

    test('no walk, breathes, RR<30, perfusion OK, no obey = RED', () {
      // walk? NO -> breathe? YES -> resp_rate<30? YES -> perfusion? YES -> mental? NO -> red
      final nodeId = engine.walkPath('walk', [false, true, true, true, false]);
      expect(engine.isResult(nodeId), isTrue);
      final result = engine.getResult(nodeId)!;
      expect(result.color, TriageColor.red);
    });

    test('getNode throws for unknown id', () {
      expect(() => engine.getNode('nonexistent'), throwsArgumentError);
    });
  });
}
