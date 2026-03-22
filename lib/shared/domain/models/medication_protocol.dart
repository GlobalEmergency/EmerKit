class Medication {
  final String name;
  final String dose;
  final Duration interval;
  final int? maxDoses;
  final String? notes;

  const Medication({
    required this.name,
    required this.dose,
    required this.interval,
    this.maxDoses,
    this.notes,
  });
}

class MedicationTracker {
  final Medication medication;
  int _dosesGiven = 0;
  DateTime? _lastAdministered;

  MedicationTracker(this.medication);

  int get dosesGiven => _dosesGiven;
  DateTime? get lastAdministered => _lastAdministered;

  bool get isMaxReached =>
      medication.maxDoses != null && _dosesGiven >= medication.maxDoses!;

  Duration? get timeSinceLastDose => _lastAdministered != null
      ? DateTime.now().difference(_lastAdministered!)
      : null;

  bool get isAlertDue {
    if (isMaxReached) return false;
    if (_lastAdministered == null) return true;
    return timeSinceLastDose! >= medication.interval;
  }

  /// Returns 0.0 (just given) to 1.0+ (overdue).
  double get urgencyRatio {
    if (_lastAdministered == null) return 1.0;
    return timeSinceLastDose!.inSeconds / medication.interval.inSeconds;
  }

  void administer() {
    _dosesGiven++;
    _lastAdministered = DateTime.now();
  }

  void reset() {
    _dosesGiven = 0;
    _lastAdministered = null;
  }
}
