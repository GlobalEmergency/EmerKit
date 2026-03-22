import 'dart:async';
import 'package:flutter/material.dart';
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

class RcpScreen extends StatefulWidget {
  const RcpScreen({super.key});

  @override
  State<RcpScreen> createState() => _RcpScreenState();
}

class _RcpScreenState extends State<RcpScreen> {
  late AudioPlayer _audioPlayer;
  Timer? _timer;
  Timer? _clockTimer;
  Timer? _medicationRefreshTimer;
  bool _isRunning = false;
  bool _flash = false;
  int _elapsedSeconds = 0;

  // Session (persists across config changes)
  late ActionLog _actionLog;
  late RcpSession _session;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
    _audioPlayer.setSource(AssetSource('audio/metronome_click.wav'));
    _actionLog = ActionLog();
    _session = RcpSession(
      mode: RcpMode.svb,
      ventilationEnabled: true,
      bpm: 120,
      actionLog: _actionLog,
      medicationTrackers: [],
    );
  }

  void _start() {
    if (_session.compressionCount == 0 &&
        _session.cycleCount == 0 &&
        _actionLog.entries.isEmpty) {
      // Fresh start
      _actionLog = ActionLog();
      _session.actionLog.clear();
      _session = RcpSession(
        mode: _session.mode,
        ventilationEnabled: _session.ventilationEnabled,
        bpm: _session.bpm,
        actionLog: _actionLog,
        medicationTrackers: _session.mode == RcpMode.sva
            ? RcpData.svaMedications.map(MedicationTracker.new).toList()
            : [],
      );
    }
    _actionLog.add(
      'RCP iniciada - ${_session.mode == RcpMode.sva ? "SVA" : "SVB"} '
          '- ${_session.bpm}bpm'
          '${_session.ventilationEnabled ? " - 30:2" : " - continuo"}',
      'evento',
    );
    setState(() {
      _isRunning = true;
      _elapsedSeconds = _actionLog.entries.isEmpty ? 0 : _elapsedSeconds;
    });
    _startMetronome();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
    if (_session.mode == RcpMode.sva) {
      _startMedicationRefresh();
    }
  }

  void _stop() {
    _timer?.cancel();
    _clockTimer?.cancel();
    _medicationRefreshTimer?.cancel();
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
      bpm: _session.bpm,
      actionLog: _actionLog,
      medicationTrackers: _session.mode == RcpMode.sva
          ? RcpData.svaMedications.map(MedicationTracker.new).toList()
          : [],
    );
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

  void _onBpmChanged(int newBpm) {
    _session.setBpm(newBpm);
    if (_isRunning && !_session.isBreathPhase) {
      _startMetronome();
    }
    setState(() {});
  }

  void _onVentilationChanged(bool enabled) {
    final wasBreathPhase = _session.isBreathPhase;
    _session.setVentilation(enabled);
    if (wasBreathPhase && !enabled && _isRunning) {
      // Was paused for breath, now continuous - restart metronome
      _startMetronome();
    }
    setState(() {});
  }

  // -- Timer logic --

  void _startMetronome() {
    _timer?.cancel();
    final interval = Duration(milliseconds: (60000 / _session.bpm).round());
    _timer = Timer.periodic(interval, (_) => _onBeat());
  }

  void _startMedicationRefresh() {
    _medicationRefreshTimer?.cancel();
    _medicationRefreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _onBeat() {
    if (_session.isBreathPhase) return;

    _audioPlayer.stop();
    _audioPlayer.resume();

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
    _audioPlayer.dispose();
    super.dispose();
  }

  // -- Banner helpers --

  String get _elapsedText {
    final min = _elapsedSeconds ~/ 60;
    final sec = _elapsedSeconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  String get _bannerValue {
    if (!_isRunning &&
        _session.compressionCount == 0 &&
        _session.cycleCount == 0 &&
        _actionLog.entries.isEmpty) {
      return '\u25b6';
    }
    if (_session.isBreathPhase) return '\u00a1VENTILAR!';
    if (!_session.ventilationEnabled) {
      return '${_session.compressionCount}';
    }
    return '${_session.compressionCount}/${RcpSession.compressionsPerCycle}';
  }

  String get _bannerLabel {
    if (!_isRunning &&
        _session.compressionCount == 0 &&
        _session.cycleCount == 0 &&
        _actionLog.entries.isEmpty) {
      return 'Pulsa Play para iniciar';
    }
    if (_session.isBreathPhase) {
      return '${RcpSession.breathsPerCycle} ventilaciones';
    }
    if (!_session.ventilationEnabled) {
      return 'Compresiones \u00b7 $_elapsedText';
    }
    return 'Ciclo ${_session.cycleCount + 1} \u00b7 $_elapsedText';
  }

  Color get _bannerColor {
    if (!_isRunning &&
        _session.compressionCount == 0 &&
        _session.cycleCount == 0 &&
        _actionLog.entries.isEmpty) {
      return Colors.grey;
    }
    if (_session.isBreathPhase) return AppColors.valoracion;
    return AppColors.soporteVital;
  }

  @override
  Widget build(BuildContext context) {
    return ToolScreenBase(
      title: 'RCP',
      onReset: _reset,
      resultWidget: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        color: _flash
            ? _bannerColor.withValues(alpha: 0.4)
            : _bannerColor.withValues(alpha: 0.12),
        child: Column(
          children: [
            Text(
              _bannerValue,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: _bannerColor,
              ),
            ),
            Text(
              _bannerLabel,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _bannerColor,
              ),
            ),
          ],
        ),
      ),
      toolBody: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Config section - ALWAYS visible, compact when running
            _buildConfigSection(),

            // Play/Stop button
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

            // SVA medications section
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

            // Action log + export
            if (_session.mode == RcpMode.sva &&
                (_isRunning || _actionLog.entries.isNotEmpty)) ...[
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

            // Info card when not running and no log
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
                            'Ratio 30:2 \u00b7 Comprimir fuerte (5-6 cm) '
                            'y rapido \u00b7 Permitir reexpansion completa',
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

  Widget _buildConfigSection() {
    if (_isRunning) {
      // Compact inline controls while running
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Wrap(
          spacing: 6,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            // Mode toggle
            ChoiceChip(
              label: const Text('SVB'),
              selected: _session.mode == RcpMode.svb,
              selectedColor: AppColors.soporteVital,
              labelStyle: TextStyle(
                color: _session.mode == RcpMode.svb ? Colors.white : null,
                fontSize: 12,
              ),
              onSelected: (_) => _onModeChanged(RcpMode.svb),
              visualDensity: VisualDensity.compact,
            ),
            ChoiceChip(
              label: const Text('SVA'),
              selected: _session.mode == RcpMode.sva,
              selectedColor: AppColors.soporteVital,
              labelStyle: TextStyle(
                color: _session.mode == RcpMode.sva ? Colors.white : null,
                fontSize: 12,
              ),
              onSelected: (_) => _onModeChanged(RcpMode.sva),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 4),
            // BPM chips
            for (final bpm in [100, 110, 120])
              ChoiceChip(
                label: Text('$bpm'),
                selected: _session.bpm == bpm,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: _session.bpm == bpm ? Colors.white : null,
                  fontSize: 12,
                ),
                onSelected: (_) => _onBpmChanged(bpm),
                visualDensity: VisualDensity.compact,
              ),
            const SizedBox(width: 4),
            // Ventilation chip
            FilterChip(
              label: const Text('30:2'),
              selected: _session.ventilationEnabled,
              selectedColor: AppColors.valoracion.withValues(alpha: 0.3),
              onSelected: _onVentilationChanged,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      );
    }

    // Full controls when stopped
    return Column(
      children: [
        // Mode selector
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SegmentedButton<RcpMode>(
            segments: const [
              ButtonSegment(value: RcpMode.svb, label: Text('SVB')),
              ButtonSegment(value: RcpMode.sva, label: Text('SVA')),
            ],
            selected: {_session.mode},
            onSelectionChanged: (selected) => _onModeChanged(selected.first),
          ),
        ),

        // BPM selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('BPM: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              for (final bpm in [100, 110, 120])
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text('$bpm'),
                    selected: _session.bpm == bpm,
                    selectedColor: AppColors.soporteVital,
                    labelStyle: TextStyle(
                      color: _session.bpm == bpm ? Colors.white : null,
                      fontWeight: _session.bpm == bpm ? FontWeight.bold : null,
                    ),
                    onSelected: (_) => _onBpmChanged(bpm),
                  ),
                ),
            ],
          ),
        ),

        // Ventilation toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SwitchListTile(
            title: const Text(
              'Parada para ventilaciones',
              style: TextStyle(fontSize: 14),
            ),
            value: _session.ventilationEnabled,
            onChanged: _onVentilationChanged,
            activeThumbColor: AppColors.soporteVital,
            dense: true,
          ),
        ),
      ],
    );
  }
}
