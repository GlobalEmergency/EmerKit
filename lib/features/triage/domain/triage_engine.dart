/// Pure Dart triage START decision engine.
/// NO Flutter imports.
library;

enum TriageColor { green, yellow, red, black }

class TriageNode {
  final String question;
  final String? action;
  final TriageColor? result;
  final String? yesNode;
  final String? noNode;

  const TriageNode({
    required this.question,
    this.action,
    this.result,
    this.yesNode,
    this.noNode,
  });

  bool get isResult => result != null;
}

class TriageResult {
  final TriageColor color;
  final String label;
  final String description;

  const TriageResult({
    required this.color,
    required this.label,
    required this.description,
  });

  static TriageResult fromColor(TriageColor color) {
    return switch (color) {
      TriageColor.green => const TriageResult(
          color: TriageColor.green,
          label: 'VERDE',
          description: 'Leve - Atención demorable',
        ),
      TriageColor.yellow => const TriageResult(
          color: TriageColor.yellow,
          label: 'AMARILLO',
          description: 'Urgente - Puede esperar',
        ),
      TriageColor.red => const TriageResult(
          color: TriageColor.red,
          label: 'ROJO',
          description: 'Inmediato',
        ),
      TriageColor.black => const TriageResult(
          color: TriageColor.black,
          label: 'NEGRO',
          description: 'Fallecido',
        ),
    };
  }
}

class TriageEngine {
  final Map<String, TriageNode> nodes;

  const TriageEngine({required this.nodes});

  TriageNode getNode(String id) {
    final node = nodes[id];
    if (node == null) {
      throw ArgumentError('Triage node "$id" not found');
    }
    return node;
  }

  bool isResult(String id) => getNode(id).isResult;

  /// Returns the [TriageResult] for a result node, or null if it is a question node.
  TriageResult? getResult(String id) {
    final node = getNode(id);
    if (node.result == null) return null;
    return TriageResult.fromColor(node.result!);
  }

  /// Follows a path of yes/no answers from [startId] and returns the final node id.
  /// [answers] is a list of booleans (true = yes, false = no).
  String walkPath(String startId, List<bool> answers) {
    var currentId = startId;
    for (final answer in answers) {
      final node = getNode(currentId);
      if (node.isResult) break;
      final nextId = answer ? node.yesNode : node.noNode;
      if (nextId == null) {
        throw StateError(
            'Node "$currentId" has no ${answer ? "yes" : "no"} branch');
      }
      currentId = nextId;
    }
    return currentId;
  }
}
