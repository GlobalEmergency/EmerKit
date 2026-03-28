import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:emerkit/shared/domain/models/action_log.dart';
import 'package:emerkit/shared/domain/models/medication_protocol.dart';
import 'package:emerkit/shared/presentation/theme/app_colors.dart';
import 'package:emerkit/shared/presentation/widgets/tool_screen_base.dart';
import 'package:emerkit/shared/presentation/widgets/tool_info_panel.dart';
import 'package:emerkit/shared/presentation/widgets/medication_alert_card.dart';
import 'package:emerkit/shared/presentation/widgets/action_log_viewer.dart';
import 'package:emerkit/shared/utils/text_exporter.dart';
import '../domain/rcp_data.dart';
import '../domain/rcp_session.dart';

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
      return 'Pulsa Play para iniciar · 120 bpm';
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
      extraActions: [
        IconButton(
          icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
          tooltip: _muted ? 'Activar sonido' : 'Silenciar',
          onPressed: () => setState(() => _muted = !_muted),
        ),
      ],
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
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _bannerColor,
                  ),
            ),
            Text(
              _bannerLabel,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
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
            // 2-minute alert banner
            if (_twoMinAlertPending)
              GestureDetector(
                onTap: _dismissTwoMinAlert,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  color: Colors.orange.shade700,
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber,
                          color: Colors.white, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'COMPROBAR PULSO / CAMBIO REANIMADOR',
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      Text(
                        'CONFIRMAR',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

            // Config section - ALWAYS visible
            _buildConfigSection(),

            // Play/Pause button
            Padding(
              padding: EdgeInsets.symmetric(vertical: _isRunning ? 12 : 24),
              child: GestureDetector(
                onTap: _isRunning ? _stop : _start,
                child: Container(
                  width: _isRunning ? 80 : 160,
                  height: _isRunning ? 80 : 160,
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
                    size: _isRunning ? 40 : 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Quick action buttons - always visible when running
            if (_isRunning) _buildQuickActions(),

            // SVA medications
            if (_session.mode == RcpMode.sva && _isRunning) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    const Icon(Icons.medication,
                        size: 20, color: AppColors.soporteVital),
                    const SizedBox(width: 8),
                    Text(
                      'Medicacion SVA',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
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
                    Expanded(
                      child: Text(
                        'Registro de acciones',
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
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
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: Colors.grey.shade600),
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

  // Action counts per id
  final Map<String, int> _actionCounts = {};

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

  int _countOf(String id) => _actionCounts[id] ?? 0;
  bool _isDone(String id) => (_actionCounts[id] ?? 0) > 0;

  Widget _actionTile({
    required String id,
    required IconData icon,
    required String label,
    required String logText,
    Color? iconColor,
    required BuildContext sheetContext,
  }) {
    final done = _isDone(id);
    final count = _countOf(id);
    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: iconColor ?? (done ? Colors.grey : null)),
          if (done)
            const Positioned(
              right: -4,
              bottom: -4,
              child: Icon(Icons.check_circle, color: Colors.green, size: 14),
            ),
        ],
      ),
      title: Text(label),
      trailing: count > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                'x$count',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
              ),
            )
          : null,
      onTap: () {
        Navigator.pop(sheetContext);
        _logQuickAction(id, logText);
      },
    );
  }

  void _showAirwayOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _actionTile(
                id: 'airway',
                icon: Icons.air,
                label: 'Apertura via aerea',
                logText: 'Apertura via aerea',
                sheetContext: ctx),
            _actionTile(
                id: 'guedel',
                icon: Icons.straighten,
                label: 'Guedel colocado',
                logText: 'Canula orofaringea (Guedel) colocada',
                sheetContext: ctx),
            _actionTile(
                id: 'iot',
                icon: Icons.masks,
                label: 'IOT realizada',
                logText: 'Intubacion orotraqueal (IOT) realizada',
                sheetContext: ctx),
            _actionTile(
                id: 'ml',
                icon: Icons.face,
                label: 'Mascarilla laringea',
                logText: 'Mascarilla laringea colocada',
                sheetContext: ctx),
            _actionTile(
                id: 'aspiration',
                icon: Icons.cancel_outlined,
                label: 'Aspiracion de secreciones',
                logText: 'Aspiracion de secreciones',
                sheetContext: ctx),
          ],
        ),
      ),
    );
  }

  Widget _resultCard({
    required BuildContext ctx,
    required String label,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: color.withValues(alpha: 0.8),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPulseOptions() {
    final pulseCount =
        _countOf('pulse_check') + _countOf('rosc') + _countOf('no_pulse');
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: AppColors.soporteVital),
                  const SizedBox(width: 8),
                  Text(
                    'Comprobar pulso',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (pulseCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        'x$pulseCount',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _resultCard(
                    ctx: ctx,
                    label: 'CON PULSO',
                    subtitle: '(ROSC)',
                    color: Colors.green,
                    icon: Icons.favorite,
                    onTap: () {
                      Navigator.pop(ctx);
                      _logQuickAction('pulse_check', 'Comprobacion de pulso');
                      _logQuickAction('rosc',
                          'ROSC - Recuperacion de circulacion espontanea');
                    },
                  ),
                  const SizedBox(width: 12),
                  _resultCard(
                    ctx: ctx,
                    label: 'SIN PULSO',
                    subtitle: '(Continuar RCP)',
                    color: Colors.red,
                    icon: Icons.heart_broken,
                    onTap: () {
                      Navigator.pop(ctx);
                      _logQuickAction('pulse_check', 'Comprobacion de pulso');
                      _logQuickAction('no_pulse', 'Sin pulso - continuar RCP');
                    },
                  ),
                ],
              ),
              const Divider(height: 24),
              _actionTile(
                  id: 'lucas',
                  icon: Icons.precision_manufacturing,
                  label: 'LUCAS colocado',
                  logText:
                      'Dispositivo LUCAS de compresiones mecanicas colocado',
                  iconColor: AppColors.tecnicas,
                  sheetContext: ctx),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeaOptions() {
    final isSvb = _session.mode == RcpMode.svb;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _actionTile(
                id: 'dea_pads',
                icon: Icons.electric_bolt,
                label: 'Parches DEA colocados',
                logText: 'Parches DEA colocados',
                sheetContext: ctx),
            ListTile(
              leading: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.search,
                      color: _isDone('rhythm') ? Colors.grey : null),
                  if (_isDone('rhythm'))
                    const Positioned(
                      right: -4,
                      bottom: -4,
                      child: Icon(Icons.check_circle,
                          color: Colors.green, size: 14),
                    ),
                ],
              ),
              title: Text(isSvb ? 'Analisis DEA' : 'Analisis de ritmo'),
              trailing: _countOf('rhythm') > 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        'x${_countOf('rhythm')}',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                      ),
                    )
                  : null,
              onTap: () {
                Navigator.pop(ctx);
                if (isSvb) {
                  _showDeaAnalysis();
                } else {
                  _showRhythmAnalysis();
                }
              },
            ),
            _actionTile(
                id: 'shock',
                icon: Icons.flash_on,
                label: 'Descarga administrada',
                logText: 'Descarga DEA administrada',
                iconColor: Colors.orange,
                sheetContext: ctx),
          ],
        ),
      ),
    );
  }

  void _showDeaAnalysis() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analisis DEA #${_countOf('rhythm') + 1}',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _resultCard(
                    ctx: ctx,
                    label: 'DESCARGA\nRECOMENDADA',
                    subtitle: 'Pulsar descarga',
                    color: Colors.red,
                    icon: Icons.flash_on,
                    onTap: () {
                      Navigator.pop(ctx);
                      _logQuickAction('rhythm', 'DEA: Descarga recomendada');
                      _logQuickAction('shock', 'Descarga DEA administrada');
                    },
                  ),
                  const SizedBox(width: 12),
                  _resultCard(
                    ctx: ctx,
                    label: 'DESCARGA NO\nRECOMENDADA',
                    subtitle: 'Continuar RCP',
                    color: Colors.blue,
                    icon: Icons.flash_off,
                    onTap: () {
                      Navigator.pop(ctx);
                      _logQuickAction('rhythm', 'DEA: Descarga no recomendada');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRhythmAnalysis() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ritmo identificado',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Analisis #${_countOf('rhythm') + 1}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                Text(
                  'DESFIBRILABLE',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _rhythmCard(
                        ctx: ctx,
                        label: 'FV',
                        subtitle: 'Fibrilacion ventricular',
                        color: Colors.red,
                        icon: Icons.show_chart,
                        shockable: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _rhythmCard(
                        ctx: ctx,
                        label: 'TVSP',
                        subtitle: 'Taquicardia ventricular sin pulso',
                        color: Colors.red,
                        icon: Icons.timeline,
                        shockable: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'NO DESFIBRILABLE',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _rhythmCard(
                        ctx: ctx,
                        label: 'Asistolia',
                        subtitle: 'Linea plana',
                        color: Colors.blue,
                        icon: Icons.horizontal_rule,
                        shockable: false,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _rhythmCard(
                        ctx: ctx,
                        label: 'AESP',
                        subtitle: 'Actividad electrica sin pulso',
                        color: Colors.blue,
                        icon: Icons.monitor_heart,
                        shockable: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'OTROS',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _rhythmCard(
                        ctx: ctx,
                        label: 'Bradicardia',
                        subtitle: 'FC < 60 lpm',
                        color: Colors.grey,
                        icon: Icons.trending_down,
                        shockable: false,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _rhythmCard(
                        ctx: ctx,
                        label: 'Taq. sinusal',
                        subtitle: 'Taquicardia sinusal',
                        color: Colors.grey,
                        icon: Icons.trending_up,
                        shockable: false,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _rhythmCard(
                        ctx: ctx,
                        label: 'BAV completo',
                        subtitle: 'Bloqueo AV 3er grado',
                        color: Colors.grey,
                        icon: Icons.block,
                        shockable: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _rhythmCard({
    required BuildContext ctx,
    required String label,
    required String subtitle,
    required Color color,
    required IconData icon,
    required bool shockable,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(ctx);
        final logText =
            'Ritmo: $label (${shockable ? "DESFIBRILABLE" : "NO desfibrilable"}) - $subtitle';
        _logQuickAction('rhythm', logText);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall!
                  .copyWith(color: color.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomEventDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registrar evento'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Descripcion del evento...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              _logCustomEvent(value.trim());
            }
            Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _logCustomEvent(controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _quickActionButton(
            icon: Icons.air,
            label: 'Via aerea',
            color: AppColors.valoracion,
            onTap: _showAirwayOptions,
            doneIds: const ['airway', 'guedel', 'iot', 'ml', 'aspiration'],
          ),
          _quickActionButton(
            icon: Icons.favorite,
            label: 'Pulso',
            color: AppColors.soporteVital,
            onTap: _showPulseOptions,
            doneIds: const ['pulse_check', 'rosc', 'no_pulse', 'lucas'],
          ),
          _quickActionButton(
            icon: Icons.electric_bolt,
            label: 'DEA',
            color: AppColors.tecnicas,
            onTap: _showDeaOptions,
            doneIds: const ['dea_pads', 'rhythm', 'shock'],
          ),
          _quickActionButton(
            icon: Icons.edit_note,
            label: 'Evento',
            color: AppColors.comunicacion,
            onTap: _showCustomEventDialog,
            doneIds: const [],
          ),
        ],
      ),
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required List<String> doneIds,
  }) {
    final anyDone = doneIds.any(_isDone);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: anyDone ? 0.25 : 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: anyDone
                        ? Border.all(color: Colors.green, width: 1.5)
                        : null,
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                if (anyDone)
                  const Positioned(
                    right: -4,
                    top: -4,
                    child:
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigSection() {
    if (_isRunning) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Wrap(
          spacing: 6,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            ChoiceChip(
              label: const Text('SVB'),
              selected: _session.mode == RcpMode.svb,
              selectedColor: AppColors.soporteVital,
              labelStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: _session.mode == RcpMode.svb ? Colors.white : null,
                  ),
              onSelected: (_) => _onModeChanged(RcpMode.svb),
              visualDensity: VisualDensity.compact,
            ),
            ChoiceChip(
              label: const Text('SVA'),
              selected: _session.mode == RcpMode.sva,
              selectedColor: AppColors.soporteVital,
              labelStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: _session.mode == RcpMode.sva ? Colors.white : null,
                  ),
              onSelected: (_) => _onModeChanged(RcpMode.sva),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
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

    return Column(
      children: [
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SwitchListTile(
            title: Text(
              'Parada para ventilaciones (30:2)',
              style: Theme.of(context).textTheme.bodyLarge,
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
