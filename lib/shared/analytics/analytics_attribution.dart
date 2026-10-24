class AnalyticsAttribution {
  final Map<String, String> _values;
  const AnalyticsAttribution._(this._values);
  const AnalyticsAttribution.empty() : _values = const {};

  factory AnalyticsAttribution.fromReferrer(String referrer) {
    try {
      final query = Uri.splitQueryString(referrer);
      return AnalyticsAttribution.fromJson({
        for (final key in ['source', 'medium', 'campaign', 'content'])
          if (query['utm_$key'] != null) key: query['utm_$key'],
      });
    } on FormatException {
      return const AnalyticsAttribution.empty();
    } on ArgumentError {
      return const AnalyticsAttribution.empty();
    }
  }

  factory AnalyticsAttribution.fromJson(Map<String, dynamic> values) {
    final safe = <String, String>{};
    for (final key in ['source', 'medium', 'campaign', 'content']) {
      final value = values[key];
      if (value is! String) continue;
      final normalized = value.toLowerCase();
      if (RegExp(r'^[a-z0-9_-]{1,48}$').hasMatch(normalized)) {
        safe[key] = normalized;
      }
    }
    return AnalyticsAttribution._(Map.unmodifiable(safe));
  }

  Map<String, String> toJson() => Map.of(_values);
}
