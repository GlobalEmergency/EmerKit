import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/theme/app_colors.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_screen_base.dart';

class RcpRithmScreen extends StatefulWidget {
  const RcpRithmScreen({super.key});

  @override
  State<RcpRithmScreen> createState() => _RcpRithmScreenState();
}

class _RcpRithmScreenState extends State<RcpRithmScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;
  bool _isRunning = false;
  int _bpm = 110;
  int _compressionCount = 0;
  int _cycleCount = 0;
  bool _isBreathPhase = false;
  int _elapsedSeconds = 0;
  Timer? _clockTimer;
  bool _flash = false;

  static const _compressionsPerCycle = 30;
  static const _breathsPerCycle = 2;

  void _start() {
    setState(() => _isRunning = true);
    _startMetronome();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
  }

  void _stop() {
    _timer?.cancel();
    _clockTimer?.cancel();
    setState(() => _isRunning = false);
  }

  void _reset() {
    _stop();
    setState(() {
      _compressionCount = 0;
      _cycleCount = 0;
      _isBreathPhase = false;
      _elapsedSeconds = 0;
    });
  }

  void _startMetronome() {
    _timer?.cancel();
    final interval = Duration(milliseconds: (60000 / _bpm).round());
    _timer = Timer.periodic(interval, (_) => _onBeat());
  }

  void _onBeat() {
    if (_isBreathPhase) return;

    setState(() {
      _compressionCount++;
      _flash = true;
    });

    // Play click sound
    _audioPlayer.play(AssetSource('audio/metronome_click.wav'));

    // Flash off after short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _flash = false);
    });

    if (_compressionCount >= _compressionsPerCycle) {
      _timer?.cancel();
      setState(() {
        _isBreathPhase = true;
        _compressionCount = 0;
      });

      // Auto-resume after breath pause (3 seconds for 2 breaths)
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted || !_isRunning) return;
        setState(() {
          _isBreathPhase = false;
          _cycleCount++;
        });
        _startMetronome();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _clockTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  String get _elapsedText {
    final min = _elapsedSeconds ~/ 60;
    final sec = _elapsedSeconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  String get _bannerValue {
    if (!_isRunning && _compressionCount == 0 && _cycleCount == 0) {
      return '▶';
    }
    if (_isBreathPhase) return '¡VENTILAR!';
    return '$_compressionCount / $_compressionsPerCycle';
  }

  String get _bannerLabel {
    if (!_isRunning && _compressionCount == 0 && _cycleCount == 0) {
      return 'Pulsa Play para iniciar';
    }
    if (_isBreathPhase) return '$_breathsPerCycle ventilaciones';
    return 'Ciclos: $_cycleCount · Tiempo: $_elapsedText';
  }

  Color get _bannerColor {
    if (!_isRunning && _compressionCount == 0 && _cycleCount == 0) {
      return Colors.grey;
    }
    if (_isBreathPhase) return AppColors.valoracion;
    return AppColors.soporteVital;
  }

  @override
  Widget build(BuildContext context) {
    return ToolScreenBase(
      title: 'Metrónomo RCP',
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
            // BPM selector
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('BPM: ', style: TextStyle(fontSize: 16)),
                  for (final bpm in [100, 110, 120])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text('$bpm'),
                        selected: _bpm == bpm,
                        selectedColor: AppColors.soporteVital,
                        labelStyle: TextStyle(
                          color: _bpm == bpm ? Colors.white : null,
                          fontWeight: _bpm == bpm ? FontWeight.bold : null,
                        ),
                        onSelected: (_) {
                          setState(() => _bpm = bpm);
                          if (_isRunning && !_isBreathPhase) _startMetronome();
                        },
                      ),
                    ),
                ],
              ),
            ),

            // Play/Stop button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: GestureDetector(
                onTap: _isRunning ? _stop : _start,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRunning ? AppColors.severitySevere : AppColors.severityMild,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRunning ? AppColors.severitySevere : AppColors.severityMild)
                            .withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRunning ? Icons.stop : Icons.play_arrow,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ratio 30:2 · Comprimir fuerte (5-6 cm) y rápido · Permitir reexpansión completa',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
      infoBody: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoCard('¿Qué es?',
                'El metrónomo de RCP es una herramienta de ayuda para mantener el ritmo adecuado '
                'de compresiones torácicas durante la reanimación cardiopulmonar (RCP). '
                'Marca el tempo de compresiones y gestiona automáticamente las pausas '
                'para ventilación siguiendo el protocolo 30:2.'),
            _infoCard('Técnica de compresión',
                'Comprimir en el centro del pecho (mitad inferior del esternón).\n'
                'Profundidad: 5-6 cm en adultos.\n'
                'Frecuencia: 100-120 compresiones por minuto.\n'
                'Permitir la reexpansión torácica completa entre compresiones.\n'
                'Minimizar las interrupciones de las compresiones.'),
            _infoCard('Ratio 30:2',
                'En RCP estándar con 2 reanimadores o con dispositivo de barrera:\n'
                '• 30 compresiones torácicas seguidas de 2 ventilaciones.\n'
                '• Cada ventilación de 1 segundo de duración.\n'
                '• Evitar hiperventilación.\n\n'
                'En RCP con vía aérea avanzada (IOT/mascarilla laríngea):\n'
                '• Compresiones continuas a 100-120/min.\n'
                '• 1 ventilación cada 6 segundos (10/min).'),
            _infoCard('Cuándo usar',
                'Parada cardiorrespiratoria en adulto.\n'
                'Como guía de ritmo para reanimadores.\n'
                'Entrenamiento y práctica de RCP.'),
            _infoCard('Referencias',
                'European Resuscitation Council Guidelines 2025. Resuscitation.\n\n'
                'Olasveengen TM, et al. European Resuscitation Council Guidelines 2025: Basic Life Support.\n\n'
                'Soar J, et al. European Resuscitation Council Guidelines 2025: Adult Advanced Life Support.'),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
