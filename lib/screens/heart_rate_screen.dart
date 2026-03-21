import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/tool_screen_base.dart';

class HeartRateScreen extends StatefulWidget {
  const HeartRateScreen({super.key});

  @override
  State<HeartRateScreen> createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen> {
  final List<DateTime> _taps = [];
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;

  int? get _bpm {
    if (_taps.length < 2) return null;
    final totalMs = _taps.last.difference(_taps.first).inMilliseconds;
    if (totalMs == 0) return null;
    return ((_taps.length - 1) * 60000 / totalMs).round();
  }

  void _tap() {
    if (!_isRunning) {
      _isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsedSeconds++);
      });
    }
    setState(() => _taps.add(DateTime.now()));
  }

  void _reset() {
    _timer?.cancel();
    setState(() { _taps.clear(); _elapsedSeconds = 0; _isRunning = false; });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  Color get _bpmColor {
    if (_bpm == null) return Colors.grey;
    if (_bpm! < 60 || _bpm! > 100) return AppColors.severityModerate;
    return AppColors.severityMild;
  }

  @override
  Widget build(BuildContext context) {
    return ToolScreenBase(
      title: 'Frecuencia Cardíaca',
      onReset: _reset,
      resultWidget: ResultBanner(
        value: _bpm != null ? '$_bpm' : '--',
        label: _bpm != null ? 'lpm' : 'Toca la pantalla con cada latido',
        subtitle: '${_taps.length} pulsaciones en ${_elapsedSeconds}s',
        color: _bpmColor,
      ),
      toolBody: GestureDetector(
        onTap: _tap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, size: 100, color: _isRunning ? AppColors.soporteVital : Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(_isRunning ? 'Toca con cada latido' : 'Toca para empezar',
                  style: TextStyle(fontSize: 18, color: _isRunning ? AppColors.soporteVital : Colors.grey)),
              const SizedBox(height: 8),
              const Text('Palpa el pulso y toca la pantalla\ncon cada pulsación',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
        ),
      ),
      infoBody: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _info('Cómo funciona', 'Toca la pantalla cada vez que sientas una pulsación. La app calcula los lpm basándose en el intervalo entre toques.'),
            _info('Valores normales (adulto)', 'Bradicardia: < 60 lpm\nNormal: 60-100 lpm\nTaquicardia: > 100 lpm'),
            _info('Puntos de palpación', 'Radial: cara anterior muñeca\nCarotídeo: lateral del cuello\nFemoral: ingle\nPedial: dorso del pie'),
            _info('Método alternativo', 'Cuenta pulsaciones durante 15 segundos y multiplica por 4.'),
            _info('Referencias',
                'PHTLS: Prehospital Trauma Life Support. 9th Edition. Jones & Bartlett, 2020.\n\n'
                'AHA Guidelines for CPR and ECC. Circulation. 2020.\n\n'
                'Bickley LS. Bates\' Guide to Physical Examination. 13th Edition. Wolters Kluwer, 2021.'),
          ],
        ),
      ),
    );
  }

  Widget _info(String title, String content) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: Padding(padding: const EdgeInsets.all(16), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(fontSize: 13, height: 1.5)),
      ],
    )),
  );
}
