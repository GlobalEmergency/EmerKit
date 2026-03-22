class ScoredItem {
  final String label;
  final String? description;
  final int score;

  const ScoredItem(
      {required this.label, this.description, required this.score});

  @override
  String toString() => 'ScoredItem($label, $score)';
}
