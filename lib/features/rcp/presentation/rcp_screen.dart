import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:navaja_suiza_sanitaria/shared/domain/models/action_log.dart';
import 'package:navaja_suiza_sanitaria/shared/domain/models/medication_protocol.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/theme/app_colors.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_screen_base.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_info_panel.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/medication_alert_card.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/action_log_viewer.dart';
import 'package:navaja_suiza_sanitaria/shared/utils/text_exporter.dart';
import '../domain/rcp_data.dart';
import '../domain/rcp_session.dart';
import 'rcp_banner.dart';
import 'rcp_config_section.dart';
import 'rcp_quick_actions.dart';

class RcpScreen extends StatefulWidget {
  const RcpScreen({super.key});

  @override
  State<RcpScreen> createState() => _RcpScreenState();
}

class _RcpScreenState extends State<RcpScreen> {
  // Audio: two players alternating (double buffer) to avoid memory leak
  // and ensure reliable playback at 120bpm (500ms intervals)
  static final _clickSource = AssetSource('audio/metronome_click.wav');
  static final _alertSource = AssetSource('audio/alert_tone.wav');
  late final AudioPlayer _playerA;
  late final AudioPlayer _playerB;
  final AudioPlayer _alertPlayer = AudioPlayer();
  bool _usePlayerA = true;
  Timer? _timer;
  Timer? _clockTimer;
  Timer? _medicationRefreshTimer;
  Timer? _twoMinTimer;
  bool _isRunning = false;
  bool _flash = false;
  bool _muted = false; // Only mutes compression clicks
  int _elapsedSeconds = 0;
  bool _twoMinAlertPending = false; // Visual alert banner

  // Fixed BPM per ERC 2025
  static const _bpm = 120;
  static final _beatInterval = Duration(milliseconds: (60000 / _bpm).round());

  // Session
  late ActionLog _actionLog;
  late RcpSession _session;

  // Action counts per id
  final Map<String, int> _actionCounts = {};

  @override
  void initState() {
    super.initState();
    _playerA = AudioPlayer();
    _playerB = AudioPlayer();
    _actionLog = ActionLog();
    _session = RcpSession(
      mode: RcpMode.svb,
      ventilationEnabled: true,
      actionLog: _actionLog,
      medicationTrackers: [],
    );
  }

  void _playClick() {
    if (_muted) return;
    final active = _usePlayerA ? _playerA : _playerB;
    final idle = _usePlayerA ? _playerB : _playerA;
    _usePlayerA = !_usePlayerA;
    idle.stop();
    active.play(_clickSource);
  }

  void _playAlert() {
    // Alert tone is NEVER muted - always plays
    _alertPlayer.stop();
    _alertPlayer.play(_alertSource);
  }

  void _onTwoMinAlert() {
    _playAlert();
    _actionLog.add(
      'ALERTA 2 min: comprobar pulso / cambio reanimador',
      'evento',
    );
    setState(() => _twoMinAlertPending = true);
  }

  void _dismissTwoMinAlert() {
    _actionLog.add('Alerta 2 min confirmada', 'evento');
    setState(() => _twoMinAlertPending = false);
  }

  void _start() {
    if (_session.compressionCount == 0 &&
        _session.cycleCount == 0 &&
        _actionLog.entries.isEmpty) {
      _actionLog = ActionLog();
      _session = RcpSession(
        mode: _session.mode,
        ventilationEnabled: _session.ventilationEnabled,
        actionLog: _actionLog,
        medicationTrackers: _session.mode == RcpMode.sva
            ? RcpData.svaMedications.map(MedicationTracker.new).toList()
            : [],
      );
    }
    _actionLog.add(
      'RCP iniciada - ${_session.mode == RcpMode.sva ? "SVA" : "SVB"}'
          '${_session.ventilationEnabled ? " - 30:2" : " - continuo"}',
      'evento',
    );
    setState(() {
      _isRunning = true;
    });
    _startMetronome();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
    // 2-minute alert: check pulse / switch rescuer
    _twoMinTimer?.cancel();
    _twoMinTimer = Timer.periodic(
      const Duration(minutes: 2),
      (_) => _onTwoMinAlert(),
    );
    if (_session.mode == RcpMode.sva) {
      _startMedicationRefresh();
    }
  }

  void _stop() {
    _timer?.cancel();
    _clockTimer?.cancel();
    _medicationRefreshTimer?.cancel();
    _twoMinTimer?.cancel();
    if (_isRunning) {
      _actionLog.add('RCP pausada', 'evento');
    }
    setState(() => _isRunning = false);
  }

  void _reset() {
    _stop();
    _actionLog = ActionLog();
    _session = RcpSession(
      mode: _session.mode,
      ventilationEnabled: _session.ventilationEnabled,
      actionLog: _actionLog,
      medicationTrackers: _session.mode == RcpMode.sva
          ? RcpData.svaMedications.map(MedicationTracker.new).toList()
          : [],
    );
    _actionCounts.clear();
    setState(() => _elapsedSeconds = 0);
  }

  // -- Config changes (work while running) --

  void _onModeChanged(RcpMode newMode) {
    final trackers = newMode == RcpMode.sva
        ? RcpData.svaMedications.map(MedicationTracker.new).toList()
        : <MedicationTracker>[];
    _session.setMode(newMode, trackers);
    if (_isRunning && newMode == RcpMode.sva) {
      _startMedicationRefresh();
    } else {
      _medicationRefreshTimer?.cancel();
    }
    setState(() {});
  }

  void _onVentilationChanged(bool enabled) {
    final wasBreathPhase = _session.isBreathPhase;
    _session.setVentilation(enabled);
    if (wasBreathPhase && !enabled && _isRunning) {
      _startMetronome();
    }
    setState(() {});
  }

  // -- Timer logic --

  void _startMetronome() {
    _timer?.cancel();
    _timer = Timer.periodic(_beatInterval, (_) => _onBeat());
  }

  void _startMedicationRefresh() {
    _medicationRefreshTimer?.cancel();
    _medicationRefreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _onBeat() {
    if (_session.isBreathPhase) return;

    _playClick();

    final shouldVentilate = _session.onCompression();

    setState(() => _flash = true);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _flash = false);
    });

    if (shouldVentilate) {
      _timer?.cancel();
      setState(() {});
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted || !_isRunning) return;
        _session.onBreathPhaseComplete();
        setState(() {});
        _startMetronome();
      });
    }
  }

  void _onAdministerMedication(MedicationTracker tracker) {
    _session.administerMedication(tracker);
    HapticFeedback.mediumImpact();
    setState(() {});
  }

  void _logQuickAction(String id, String logText) {
    _actionCounts[id] = (_actionCounts[id] ?? 0) + 1;
    _actionLog.add(logText, 'evento');
    HapticFeedback.lightImpact();
    setState(() {});
  }

  void _logCustomEvent(String text) {
    _actionLog.add(text, 'evento');
    HapticFeedback.lightImpact();
    setState(() {});
  }

  void _exportLog() {
    final text = _actionLog.toFormattedText();
    TextExporter.copyToClipboard(text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro copiado al portapapeles'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _clockTimer?.cancel();
    _medicationRefreshTimer?.cancel();
    _twoMinTimer?.cancel();
    _playerA.dispose();
    _playerB.dispose();
    _alertPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ToolScreenBase(
      title: 'RCP',
      onReset: _reset,
      extraActions: [
        IconButton(
          icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
          tooltip: _muted ? 'Activar sonido' : 'Silenciar',
          onPressed: () => setState(() => _muted = !_muted),
        ),
      ],
      resultWidget: RcpBanner(
        isRunning: _isRunning,
        compressionCount: _session.compressionCount,
        cycleCount: _session.cycleCount,
        ventilationEnabled: _session.ventilationEnabled,
        isBreathPhase: _session.isBreathPhase,
        elapsedSeconds: _elapsedSeconds,
        flash: _flash,
        hasEntries: _actionLog.entries.isNotEmpty,
      ),
      toolBody: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 2-minute alert banner
            if (_twoMinAlertPending)
              GestureDetector(
                onTap: _dismissTwoMinAlert,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  color: Colors.orange.shade700,
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.white, size: 24),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'COMPROBAR PULSO / CAMBIO REANIMADOR',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        'CONFIRMAR',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Config section - ALWAYS visible
            RcpConfigSection(
              isRunning: _isRunning,
              mode: _session.mode,
              ventilationEnabled: _session.ventilationEnabled,
              onModeChanged: _onModeChanged,
              onVentilationChanged: _onVentilationChanged,
            ),

            // Play/Pause button
            Padding(
              padding: EdgeInsets.symmetric(vertical: _isRunning ? 12 : 24),
              child: GestureDetector(
                onTap: _isRunning ? _stop : _start,
                child: Container(
                  width: _isRunning ? 100 : 160,
                  height: _isRunning ? 100 : 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRunning
                        ? AppColors.severitySevere
                        : AppColors.severityMild,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRunning
                                ? AppColors.severitySevere
                                : AppColors.severityMild)
                            .withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRunning ? Icons.pause : Icons.play_arrow,
                    size: _isRunning ? 50 : 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Quick action buttons - always visible when running
            if (_isRunning)
              RcpQuickActions(
                actionCounts: _actionCounts,
                mode: _session.mode,
                onLogAction: _logQuickAction,
                onLogCustomEvent: _logCustomEvent,
              ),

            // SVA medications
            if (_session.mode == RcpMode.sva && _isRunning) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.medication,
                        size: 20, color: AppColors.soporteVital),
                    SizedBox(width: 8),
                    Text(
                      'Medicacion SVA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.soporteVital,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: _session.medicationTrackers
                      .map(
                        (tracker) => MedicationAlertCard(
                          tracker: tracker,
                          onAdminister: () => _onAdministerMedication(tracker),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],

            // Action log - visible whenever there are entries
            if (_isRunning || _actionLog.entries.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const Icon(Icons.list_alt,
                        size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Registro de acciones',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      tooltip: 'Copiar registro',
                      onPressed: _exportLog,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 200,
                child: ActionLogViewer(actionLog: _actionLog),
              ),
            ],

            // Info card
            if (!_isRunning && _actionLog.entries.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: Colors.grey, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '120 bpm \u00b7 Ratio 30:2 \u00b7 Comprimir fuerte '
                            '(5-6 cm) \u00b7 Permitir reexpansion completa',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      infoBody: const ToolInfoPanel(
        sections: RcpData.infoSections,
        references: RcpData.references,
      ),
    );
  }
}
