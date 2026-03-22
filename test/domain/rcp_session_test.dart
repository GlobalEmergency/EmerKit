import 'package:flutter_test/flutter_test.dart';
import 'package:navaja_suiza_sanitaria/shared/domain/models/action_log.dart';
import 'package:navaja_suiza_sanitaria/shared/domain/models/medication_protocol.dart';
import 'package:navaja_suiza_sanitaria/features/rcp/domain/rcp_data.dart';
import 'package:navaja_suiza_sanitaria/features/rcp/domain/rcp_session.dart';

void main() {
  group('RCP SVB - ciclo de 30 compresiones', () {
    test('compression count resets after 30 when ventilation enabled', () {
      final session = RcpSession(
        mode: RcpMode.svb,
        ventilationEnabled: true,
        actionLog: ActionLog(),
      );

      // 29 compressions - should not trigger breath phase
      for (var i = 0; i < 29; i++) {
        final result = session.onCompression();
        expect(result, isFalse);
      }
      expect(session.compressionCount, 29);
      expect(session.isBreathPhase, isFalse);

      // 30th compression triggers breath phase
      final result = session.onCompression();
      expect(result, isTrue);
      expect(session.compressionCount, 0);
      expect(session.isBreathPhase, isTrue);
    });

    test('cycle count increments after breath phase completes', () {
      final session = RcpSession(
        mode: RcpMode.svb,
        ventilationEnabled: true,
        actionLog: ActionLog(),
      );

      // Complete first cycle
      for (var i = 0; i < 30; i++) {
        session.onCompression();
      }
      expect(session.cycleCount, 0);

      session.onBreathPhaseComplete();
      expect(session.cycleCount, 1);
      expect(session.isBreathPhase, isFalse);
    });
  });

  group('RCP SVB sin ventilacion - compresiones continuas', () {
    test('no breath phase without ventilation', () {
      final session = RcpSession(
        mode: RcpMode.svb,
        ventilationEnabled: false,
        actionLog: ActionLog(),
      );

      // Do 60 compressions - never enters breath phase
      for (var i = 0; i < 60; i++) {
        final result = session.onCompression();
        expect(result, isFalse);
      }
      expect(session.isBreathPhase, isFalse);
      expect(session.compressionCount, 60);
    });
  });

  group('RCP SVA - medicacion avanzada', () {
    test('medication trackers initialized in SVA mode', () {
      final trackers =
          RcpData.svaMedications.map(MedicationTracker.new).toList();
      final session = RcpSession(
        mode: RcpMode.sva,
        ventilationEnabled: true,
        actionLog: ActionLog(),
        medicationTrackers: trackers,
      );

      expect(session.medicationTrackers.length, 4);
      expect(session.medicationTrackers[0].medication.name, 'Adrenalina');
      expect(session.medicationTrackers[1].medication.name, 'Amiodarona');
      expect(session.medicationTrackers[2].medication.name, 'Atropina');
      expect(session.medicationTrackers[3].medication.name, 'Bicarbonato');
    });

    test('medication administration logs to action log', () {
      final log = ActionLog();
      final trackers =
          RcpData.svaMedications.map(MedicationTracker.new).toList();
      final session = RcpSession(
        mode: RcpMode.sva,
        ventilationEnabled: true,
        actionLog: log,
        medicationTrackers: trackers,
      );

      // Administer adrenaline
      session.administerMedication(trackers[0]);

      expect(log.entries.length, 1);
      expect(log.entries[0].action, contains('Adrenalina'));
      expect(log.entries[0].action, contains('1mg IV/IO'));
      expect(log.entries[0].action, contains('Dosis #1'));
      expect(log.entries[0].category, 'medicacion');
    });

    test('medication respects max doses', () {
      final log = ActionLog();
      final tracker = MedicationTracker(
        const Medication(
          name: 'Amiodarona',
          dose: '300mg IV',
          interval: Duration.zero,
          maxDoses: 2,
          notes: '2\u00aa dosis: 150mg',
        ),
      );
      final session = RcpSession(
        mode: RcpMode.sva,
        ventilationEnabled: true,
        actionLog: log,
        medicationTrackers: [tracker],
      );

      session.administerMedication(tracker);
      session.administerMedication(tracker);
      expect(tracker.dosesGiven, 2);

      // Third attempt should be ignored
      session.administerMedication(tracker);
      expect(tracker.dosesGiven, 2);
      expect(log.entries.length, 2);
    });
  });

  group('RCP sesion - formato de registro', () {
    test('action log formatted text includes session info', () {
      final log = ActionLog();
      log.add('RCP iniciada - SVA - 120bpm - 30:2', 'evento');
      log.add('Adrenalina 1mg IV/IO - Dosis #1', 'medicacion');

      final text = log.toFormattedText();
      expect(text, contains('RCP Session'));
      expect(text, contains('Duration:'));
      expect(text, contains('Adrenalina'));
    });

    test('reset clears session state', () {
      final log = ActionLog();
      final trackers =
          RcpData.svaMedications.map(MedicationTracker.new).toList();
      final session = RcpSession(
        mode: RcpMode.sva,
        ventilationEnabled: true,
        actionLog: log,
        medicationTrackers: trackers,
      );

      // Build up state
      for (var i = 0; i < 30; i++) {
        session.onCompression();
      }
      session.onBreathPhaseComplete();
      session.administerMedication(trackers[0]);

      // Reset
      session.reset();

      expect(session.compressionCount, 0);
      expect(session.cycleCount, 0);
      expect(session.isBreathPhase, isFalse);
      expect(log.entries, isEmpty);
      expect(trackers[0].dosesGiven, 0);
    });
  });
}
