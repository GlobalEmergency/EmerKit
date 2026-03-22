import 'package:navaja_suiza_sanitaria/shared/domain/models/action_log.dart';
import 'package:navaja_suiza_sanitaria/shared/domain/models/medication_protocol.dart';

enum RcpMode { svb, sva }

class RcpSession {
  RcpMode mode;
  bool ventilationEnabled;
  int bpm;
  final ActionLog actionLog;
  List<MedicationTracker> medicationTrackers;

  int compressionCount = 0;
  int cycleCount = 0;
  bool isBreathPhase = false;

  static const compressionsPerCycle = 30;
  static const breathsPerCycle = 2;

  RcpSession({
    required this.mode,
    required this.ventilationEnabled,
    required this.bpm,
    required this.actionLog,
    List<MedicationTracker>? medicationTrackers,
  }) : medicationTrackers = medicationTrackers ?? [];

  /// Registers a compression beat. Returns true if breath phase should start.
  bool onCompression() {
    compressionCount++;
    if (ventilationEnabled && compressionCount >= compressionsPerCycle) {
      isBreathPhase = true;
      compressionCount = 0;
      return true;
    }
    return false;
  }

  /// Call when breath phase finishes.
  void onBreathPhaseComplete() {
    isBreathPhase = false;
    cycleCount++;
    actionLog.add(
      'Ciclo $cycleCount completado (30:2)',
      'ventilacion',
    );
  }

  /// Switch ventilation mode mid-session.
  void setVentilation(bool enabled) {
    if (ventilationEnabled == enabled) return;
    ventilationEnabled = enabled;
    if (!enabled && isBreathPhase) {
      isBreathPhase = false;
    }
    actionLog.add(
      enabled ? 'Ventilacion activada (30:2)' : 'Compresiones continuas',
      'evento',
    );
  }

  /// Switch SVB/SVA mode mid-session.
  void setMode(RcpMode newMode, List<MedicationTracker> trackers) {
    if (mode == newMode) return;
    mode = newMode;
    medicationTrackers = trackers;
    actionLog.add(
      'Cambio a ${newMode == RcpMode.sva ? 'SVA' : 'SVB'}',
      'evento',
    );
  }

  /// Change BPM mid-session.
  void setBpm(int newBpm) {
    if (bpm == newBpm) return;
    bpm = newBpm;
    actionLog.add('Frecuencia: $newBpm bpm', 'evento');
  }

  /// Administers a medication and logs it.
  void administerMedication(MedicationTracker tracker) {
    if (tracker.isMaxReached) return;
    tracker.administer();
    final doseInfo = tracker.dosesGiven == 2 &&
            tracker.medication.notes != null &&
            tracker.medication.notes!.contains('dosis')
        ? ' (${tracker.medication.notes})'
        : '';
    actionLog.add(
      '${tracker.medication.name} ${tracker.medication.dose}'
          '$doseInfo - Dosis #${tracker.dosesGiven}',
      'medicacion',
    );
  }

  void reset() {
    compressionCount = 0;
    cycleCount = 0;
    isBreathPhase = false;
    actionLog.clear();
    for (final tracker in medicationTrackers) {
      tracker.reset();
    }
  }
}
