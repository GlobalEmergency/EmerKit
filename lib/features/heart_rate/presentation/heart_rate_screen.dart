import 'dart:async';
import 'package:flutter/material.dart';
import 'package:emerkit/shared/domain/entities/severity.dart';
import 'package:emerkit/shared/presentation/theme/app_colors.dart';
import 'package:emerkit/shared/presentation/widgets/tool_screen_base.dart';
import 'package:emerkit/shared/presentation/widgets/result_banner.dart';
import 'package:emerkit/shared/presentation/widgets/tool_info_panel.dart';
import '../domain/heart_rate_calculator.dart';
import '../domain/heart_rate_data.dart';

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

  HeartRateResult? get _result => HeartRateCalculator.calculateBpm(_taps);

  Color _colorForResult(HeartRateResult? result) {
    if (result == null) return Colors.grey;
    switch (result.severity.level) {
      case SeverityLevel.mild:
        return AppColors.severityMild;
      case SeverityLevel.moderate:
        return AppColors.severityModerate;
      case SeverityLevel.severe:
        return AppColors.severitySevere;
    }
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
    setState(() {
      _taps.clear();
      _elapsedSeconds = 0;
      _isRunning = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final color = _colorForResult(result);

    return ToolScreenBase(
      title: 'Frecuencia Cardiaca',
      onReset: _reset,
      resultWidget: ResultBanner(
        value: result != null ? '${result.bpm}' : '--',
        label: result != null ? 'lpm' : 'Toca la pantalla con cada latido',
        subtitle: '${_taps.length} pulsaciones en ${_elapsedSeconds}s',
        color: color,
      ),
      toolBody: GestureDetector(
        onTap: _tap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite,
                  size: 100,
                  color: _isRunning
                      ? AppColors.soporteVital
                      : Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                _isRunning ? 'Toca con cada latido' : 'Toca para empezar',
                style: TextStyle(
                    fontSize: 18,
                    color: _isRunning ? AppColors.soporteVital : Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'Palpa el pulso y toca la pantalla\ncon cada pulsacion',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      infoBody: const ToolInfoPanel(
        sections: HeartRateData.infoSections,
        references: HeartRateData.references,
      ),
    );
  }
}
