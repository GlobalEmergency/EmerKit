import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/theme/app_colors.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_screen_base.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/result_banner.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_info_panel.dart';
import '../domain/triage_engine.dart';
import '../domain/triage_data.dart';

class TriageScreen extends StatefulWidget {
  const TriageScreen({super.key});

  @override
  State<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends State<TriageScreen> {
  static const _engine = TriageEngine(nodes: TriageData.triageNodes);

  String _currentNodeId = TriageData.startNodeId;
  final List<String> _history = [];

  TriageNode get _currentNode => _engine.getNode(_currentNodeId);

  void _answer(bool yes) {
    _history.add(_currentNodeId);
    final nextId = yes ? _currentNode.yesNode! : _currentNode.noNode!;
    setState(() => _currentNodeId = nextId);
  }

  void _goBack() {
    if (_history.isEmpty) return;
    setState(() => _currentNodeId = _history.removeLast());
  }

  void _reset() {
    setState(() {
      _currentNodeId = TriageData.startNodeId;
      _history.clear();
    });
  }

  Color _colorForTriageColor(TriageColor c) => switch (c) {
        TriageColor.green => AppColors.triageGreen,
        TriageColor.yellow => AppColors.triageYellow,
        TriageColor.red => AppColors.triageRed,
        TriageColor.black => AppColors.triageBlack,
      };

  @override
  Widget build(BuildContext context) {
    final result = _engine.getResult(_currentNodeId);

    return ToolScreenBase(
      title: 'Triage START',
      onReset: _reset,
      emptyResultText: 'Responde las preguntas',
      resultWidget: result != null
          ? ResultBanner(
              value: result.label,
              label: result.description,
              color: _colorForTriageColor(result.color),
            )
          : null,
      toolBody: result != null
          ? _buildResult(result)
          : _buildQuestion(),
      infoBody: const ToolInfoPanel(
        sections: TriageData.infoSections,
        references: TriageData.references,
      ),
    );
  }

  Widget _buildQuestion() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_currentNode.action != null) ...[
            Card(
              color: AppColors.severityModerate.withValues(alpha: 0.15),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.severityModerate),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _currentNode.action!,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          Text(
            _currentNode.question,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.severityMild),
                    onPressed: () => _answer(true),
                    child: const Text('SI', style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.severitySevere),
                    onPressed: () => _answer(false),
                    child: const Text('NO', style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
          if (_history.isNotEmpty) ...[
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: _goBack,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver atrás'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResult(TriageResult result) {
    final color = _colorForTriageColor(result.color);
    final (label, description) = switch (result.color) {
      TriageColor.green => (
          'VERDE - Leve',
          'Paciente que puede caminar. Atención demorable.',
        ),
      TriageColor.yellow => (
          'AMARILLO - Urgente',
          'Paciente que respira, tiene perfusión y responde a órdenes. Atención urgente pero puede esperar.',
        ),
      TriageColor.red => (
          'ROJO - Inmediato',
          'Paciente que necesita atención inmediata. Compromiso de vía aérea, respiración o circulación.',
        ),
      TriageColor.black => (
          'NEGRO - Fallecido',
          'No respira tras apertura de vía aérea.',
        ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                result.color == TriageColor.black ? Icons.close : Icons.check,
                size: 60,
                color: result.color == TriageColor.yellow ? Colors.black : Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              label,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color == AppColors.triageYellow ? Colors.black87 : color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh),
              label: const Text('Nuevo triage'),
            ),
          ],
        ),
      ),
    );
  }
}
