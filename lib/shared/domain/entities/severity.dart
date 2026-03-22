enum SeverityLevel { mild, moderate, severe }

class Severity {
  final String label;
  final SeverityLevel level;

  const Severity({required this.label, required this.level});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Severity && label == other.label && level == other.level;

  @override
  int get hashCode => label.hashCode ^ level.hashCode;

  @override
  String toString() => 'Severity($label, $level)';
}
