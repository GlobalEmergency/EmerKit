class ActionLogEntry {
  final DateTime timestamp;
  final String action;

  /// One of: "medicacion", "compresion", "ventilacion", "evento"
  final String category;

  const ActionLogEntry({
    required this.timestamp,
    required this.action,
    required this.category,
  });
}

class ActionLog {
  final DateTime startTime;
  final List<ActionLogEntry> _entries = [];

  ActionLog() : startTime = DateTime.now();

  List<ActionLogEntry> get entries => List.unmodifiable(_entries);

  void add(String action, String category) {
    _entries.add(
      ActionLogEntry(
        timestamp: DateTime.now(),
        action: action,
        category: category,
      ),
    );
  }

  Duration get elapsed => DateTime.now().difference(startTime);

  void clear() {
    _entries.clear();
  }

  String toFormattedText() {
    final now = DateTime.now();
    final totalElapsed = now.difference(startTime);
    final date = '${startTime.day.toString().padLeft(2, '0')}/'
        '${startTime.month.toString().padLeft(2, '0')}/'
        '${startTime.year}';
    final durationStr = _formatDuration(totalElapsed);

    final buffer = StringBuffer();
    buffer.writeln('RCP Session - $date');
    buffer.writeln('Duration: $durationStr');
    buffer.writeln('---');

    for (final entry in _entries) {
      final relative = entry.timestamp.difference(startTime);
      final mm = relative.inMinutes.toString().padLeft(2, '0');
      final ss = (relative.inSeconds % 60).toString().padLeft(2, '0');
      buffer.writeln('$mm:$ss - ${entry.action}');
    }

    return buffer.toString().trimRight();
  }

  static String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
