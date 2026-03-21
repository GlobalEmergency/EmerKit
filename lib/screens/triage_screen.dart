import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/tool_screen_base.dart';

enum _TriageResult { green, yellow, red, black }

class _TriageNode {
  final String question;
  final String? action;
  final _TriageResult? result;
  final String? yesNode;
  final String? noNode;

  const _TriageNode({
    required this.question,
    this.action,
    this.result,
    this.yesNode,
    this.noNode,
  });
}

final _triageNodes = {
  'walk': const _TriageNode(
    question: '¿Puede caminar?',
    yesNode: 'green',
    noNode: 'breathe',
  ),
  'green': const _TriageNode(
    question: '',
    result: _TriageResult.green,
  ),
  'breathe': const _TriageNode(
    question: '¿Respira?',
    yesNode: 'resp_rate',
    noNode: 'open_airway',
  ),
  'open_airway': const _TriageNode(
    question: '¿Respira tras abrir vía aérea?',
    action: 'Abrir vía aérea (maniobra frente-mentón)',
    yesNode: 'red_immediate',
    noNode: 'black',
  ),
  'black': const _TriageNode(
    question: '',
    result: _TriageResult.black,
  ),
  'resp_rate': const _TriageNode(
    question: '¿Frecuencia respiratoria < 30 rpm?',
    yesNode: 'perfusion',
    noNode: 'red_immediate',
  ),
  'perfusion': const _TriageNode(
    question: '¿Relleno capilar < 2 segundos?\n(o pulso radial presente)',
    yesNode: 'mental_status',
    noNode: 'red_immediate',
  ),
  'mental_status': const _TriageNode(
    question: '¿Obedece órdenes simples?',
    yesNode: 'yellow',
    noNode: 'red_immediate',
  ),
  'yellow': const _TriageNode(
    question: '',
    result: _TriageResult.yellow,
  ),
  'red_immediate': const _TriageNode(
    question: '',
    result: _TriageResult.red,
  ),
};

class TriageScreen extends StatefulWidget {
  const TriageScreen({super.key});

  @override
  State<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends State<TriageScreen> {
  String _currentNodeId = 'walk';
  final List<String> _history = [];

  _TriageNode get _currentNode => _triageNodes[_currentNodeId]!;

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
      _currentNodeId = 'walk';
      _history.clear();
    });
  }

  (Color, String, String)? get _resultData {
    final result = _currentNode.result;
    if (result == null) return null;
    return switch (result) {
      _TriageResult.green => (
          AppColors.triageGreen,
          'VERDE',
          'Leve - Atención demorable',
        ),
      _TriageResult.yellow => (
          AppColors.triageYellow,
          'AMARILLO',
          'Urgente - Puede esperar',
        ),
      _TriageResult.red => (
          AppColors.triageRed,
          'ROJO',
          'Inmediato',
        ),
      _TriageResult.black => (
          AppColors.triageBlack,
          'NEGRO',
          'Fallecido',
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final data = _resultData;

    return ToolScreenBase(
      title: 'Triage START',
      onReset: _reset,
      emptyResultText: 'Responde las preguntas',
      resultWidget: data != null
          ? ResultBanner(
              value: data.$2,
              label: data.$3,
              color: data.$1,
            )
          : null,
      toolBody: _currentNode.result != null
          ? _buildResult(_currentNode.result!)
          : _buildQuestion(),
      infoBody: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoCard('¿Qué es?',
                'El triage START (Simple Triage and Rapid Treatment) es un sistema de clasificación '
                'de víctimas diseñado para incidentes con múltiples víctimas (IMV). Permite una valoración '
                'rápida en menos de 60 segundos por paciente, priorizando la atención según la gravedad.'),
            _infoCard('Cuándo utilizarlo',
                'Incidentes con múltiples víctimas (IMV)\n'
                'Catástrofes y desastres\n'
                'Situaciones con recursos sanitarios limitados\n'
                'Cuando es necesario priorizar la atención de múltiples pacientes'),
            _infoCard('Interpretación de colores',
                'VERDE (Leve): Paciente que puede caminar. Atención demorable.\n\n'
                'AMARILLO (Urgente): Respira, tiene perfusión adecuada y obedece órdenes. '
                'Requiere atención urgente pero puede esperar.\n\n'
                'ROJO (Inmediato): Compromiso de vía aérea, respiración (FR >= 30) o '
                'circulación (relleno capilar >= 2s) o no obedece órdenes. Atención inmediata.\n\n'
                'NEGRO (Fallecido): No respira ni siquiera tras apertura de vía aérea.'),
            _infoCard('Referencias',
                'Simple Triage and Rapid Treatment (START). Newport Beach Fire Department, 1983.\n\n'
                'PHTLS: Prehospital Trauma Life Support. 9th Edition. Jones & Bartlett, 2020.'),
          ],
        ),
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
                    Expanded(child: Text(_currentNode.action!, style: const TextStyle(fontWeight: FontWeight.w500))),
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
                    child: const Text('SÍ', style: TextStyle(fontSize: 20, color: Colors.white)),
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

  Widget _buildResult(_TriageResult result) {
    final (color, label, description) = switch (result) {
      _TriageResult.green => (
          AppColors.triageGreen,
          'VERDE - Leve',
          'Paciente que puede caminar. Atención demorable.',
        ),
      _TriageResult.yellow => (
          AppColors.triageYellow,
          'AMARILLO - Urgente',
          'Paciente que respira, tiene perfusión y responde a órdenes. Atención urgente pero puede esperar.',
        ),
      _TriageResult.red => (
          AppColors.triageRed,
          'ROJO - Inmediato',
          'Paciente que necesita atención inmediata. Compromiso de vía aérea, respiración o circulación.',
        ),
      _TriageResult.black => (
          AppColors.triageBlack,
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
                result == _TriageResult.black ? Icons.close : Icons.check,
                size: 60,
                color: result == _TriageResult.yellow ? Colors.black : Colors.white,
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
