import 'dart:async';
import 'package:flutter/material.dart';
import 'package:emerkit/shared/domain/entities/severity.dart';
import 'package:emerkit/shared/presentation/theme/app_colors.dart';
import 'package:emerkit/shared/presentation/widgets/tool_screen_base.dart';
import 'package:emerkit/shared/presentation/widgets/result_banner.dart';
import 'package:emerkit/shared/presentation/widgets/tool_info_panel.dart';
import '../domain/respiratory_rate_calculator.dart';
import '../domain/respiratory_rate_data.dart';

class RespiratoryRateScreen extends StatefulWidget {
  const RespiratoryRateScreen({super.key});

  @override
  State<RespiratoryRateScreen> createState() => _RespiratoryRateScreenState();
}

class _RespiratoryRateScreenState extends State<RespiratoryRateScreen>
    with SingleTickerProviderStateMixin {
  final List<Breath> _breaths = [];
  DateTime? _currentInspStart;
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  bool _isInspiring = false;
  int _inspMs = 0;

  // Timer for updating inspiration duration counter
  Timer? _inspTimer;

  RespiratoryAnalysis? get _analysis =>
      RespiratoryRateCalculator.analyzeBreathing(_breaths);

  Color _colorForSeverity(SeverityLevel? level) {
    if (level == null) return Colors.grey;
    switch (level) {
      case SeverityLevel.mild:
        return AppColors.severityMild;
      case SeverityLevel.moderate:
        return AppColors.severityModerate;
      case SeverityLevel.severe:
        return AppColors.severitySevere;
    }
  }

  void _onPressStart(TapDownDetails _) {
    final now = DateTime.now();
    if (!_isRunning) {
      _isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsedSeconds++);
      });
    }
    _currentInspStart = now;
    _inspMs = 0;
    _inspTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_currentInspStart != null) {
        setState(() {
          _inspMs =
              DateTime.now().difference(_currentInspStart!).inMilliseconds;
        });
      }
    });
    setState(() => _isInspiring = true);
  }

  void _onPressEnd(TapUpDetails _) {
    _finishInspiration();
  }

  void _onPressCancel() {
    _finishInspiration();
  }

  void _finishInspiration() {
    _inspTimer?.cancel();
    if (_currentInspStart == null) return;
    final now = DateTime.now();
    // Ignore very short presses (< 200ms) as accidental taps
    if (now.difference(_currentInspStart!).inMilliseconds < 200) {
      setState(() {
        _isInspiring = false;
        _currentInspStart = null;
        _inspMs = 0;
      });
      return;
    }
    setState(() {
      _breaths.add(Breath(
        inspirationStart: _currentInspStart!,
        inspirationEnd: now,
      ));
      _isInspiring = false;
      _currentInspStart = null;
      _inspMs = 0;
    });
  }

  void _reset() {
    _timer?.cancel();
    _inspTimer?.cancel();
    setState(() {
      _breaths.clear();
      _currentInspStart = null;
      _elapsedSeconds = 0;
      _isRunning = false;
      _isInspiring = false;
      _inspMs = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _inspTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analysis = _analysis;
    final color = _colorForSeverity(analysis?.severity.level);

    // Banner content
    String bannerValue;
    String bannerLabel;
    String? bannerSubtitle;

    if (analysis != null) {
      bannerValue = '${analysis.rpm}';
      bannerLabel = 'rpm \u00b7 ${analysis.pattern.label}';
      bannerSubtitle = '${analysis.pattern.description}\n'
          'I:E ${analysis.ieRatioFormatted} \u00b7 '
          '${analysis.regularityLabel} \u00b7 '
          '${_breaths.length} resp. en ${_elapsedSeconds}s';
    } else {
      bannerValue = '--';
      bannerLabel = 'Manten pulsado durante la inspiracion';
      bannerSubtitle =
          '${_breaths.length} respiraciones en ${_elapsedSeconds}s';
    }

    return ToolScreenBase(
      title: 'Frecuencia Respiratoria',
      onReset: _reset,
      resultWidget: ResultBanner(
        value: bannerValue,
        label: bannerLabel,
        subtitle: bannerSubtitle,
        color: color,
        severityLevel: analysis?.severity.level,
      ),
      toolBody: GestureDetector(
        onTapDown: _onPressStart,
        onTapUp: _onPressEnd,
        onTapCancel: _onPressCancel,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: _isInspiring ? 1.3 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: Icon(
                  Icons.air,
                  size: 100,
                  color: _isInspiring
                      ? AppColors.soporteVital
                      : _isRunning
                          ? AppColors.signosValores
                          : Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 16),
              if (_isInspiring)
                Text(
                  'Inspirando... ${(_inspMs / 1000).toStringAsFixed(1)}s',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.soporteVital,
                      ),
                )
              else if (_isRunning)
                Text(
                  'Espirando...',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: AppColors.signosValores.withValues(alpha: 0.7),
                      ),
                )
              else
                Text(
                  'Manten pulsado para empezar',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.grey),
                ),
              const SizedBox(height: 8),
              Text(
                'Pulsa mientras el paciente inspira\ny suelta cuando espire',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      infoBody: const ToolInfoPanel(
        sections: RespiratoryRateData.infoSections,
        references: RespiratoryRateData.references,
      ),
    );
  }
}
