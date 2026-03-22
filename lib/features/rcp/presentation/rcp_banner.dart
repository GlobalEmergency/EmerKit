import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/theme/app_colors.dart';
import '../domain/rcp_session.dart';

/// Animated banner showing compression count, cycle info, or breath phase.
class RcpBanner extends StatelessWidget {
  const RcpBanner({
    super.key,
    required this.isRunning,
    required this.compressionCount,
    required this.cycleCount,
    required this.ventilationEnabled,
    required this.isBreathPhase,
    required this.elapsedSeconds,
    required this.flash,
    required this.hasEntries,
  });

  final bool isRunning;
  final int compressionCount;
  final int cycleCount;
  final bool ventilationEnabled;
  final bool isBreathPhase;
  final int elapsedSeconds;
  final bool flash;
  final bool hasEntries;

  String get _elapsedText {
    final min = elapsedSeconds ~/ 60;
    final sec = elapsedSeconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  bool get _isInitialState =>
      !isRunning && compressionCount == 0 && cycleCount == 0 && !hasEntries;

  String get _bannerValue {
    if (_isInitialState) return '\u25b6';
    if (isBreathPhase) return '\u00a1VENTILAR!';
    if (!ventilationEnabled) return '$compressionCount';
    return '$compressionCount/${RcpSession.compressionsPerCycle}';
  }

  String get _bannerLabel {
    if (_isInitialState) return 'Pulsa Play para iniciar \u00b7 120 bpm';
    if (isBreathPhase) return '${RcpSession.breathsPerCycle} ventilaciones';
    if (!ventilationEnabled) return 'Compresiones \u00b7 $_elapsedText';
    return 'Ciclo ${cycleCount + 1} \u00b7 $_elapsedText';
  }

  Color get _bannerColor {
    if (_isInitialState) return Colors.grey;
    if (isBreathPhase) return AppColors.valoracion;
    return AppColors.soporteVital;
  }

  @override
  Widget build(BuildContext context) {
    final color = _bannerColor;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      color:
          flash ? color.withValues(alpha: 0.4) : color.withValues(alpha: 0.12),
      child: Column(
        children: [
          Text(
            _bannerValue,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            _bannerLabel,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
