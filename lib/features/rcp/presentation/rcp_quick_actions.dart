import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/theme/app_colors.dart';
import '../domain/rcp_session.dart';

/// Quick action buttons bar and all associated bottom sheet dialogs.
class RcpQuickActions extends StatelessWidget {
  const RcpQuickActions({
    super.key,
    required this.actionCounts,
    required this.mode,
    required this.onLogAction,
    required this.onLogCustomEvent,
  });

  final Map<String, int> actionCounts;
  final RcpMode mode;
  final void Function(String id, String logText) onLogAction;
  final void Function(String text) onLogCustomEvent;

  int _countOf(String id) => actionCounts[id] ?? 0;
  bool _isDone(String id) => (actionCounts[id] ?? 0) > 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _quickActionButton(
            context: context,
            icon: Icons.air,
            label: 'Via aerea',
            color: AppColors.valoracion,
            onTap: () => _showAirwayOptions(context),
            doneIds: const ['airway', 'guedel', 'iot', 'ml', 'aspiration'],
          ),
          _quickActionButton(
            context: context,
            icon: Icons.favorite,
            label: 'Pulso',
            color: AppColors.soporteVital,
            onTap: () => _showPulseOptions(context),
            doneIds: const ['pulse_check', 'rosc', 'no_pulse', 'lucas'],
          ),
          _quickActionButton(
            context: context,
            icon: Icons.electric_bolt,
            label: 'DEA',
            color: AppColors.tecnicas,
            onTap: () => _showDeaOptions(context),
            doneIds: const ['dea_pads', 'rhythm', 'shock'],
          ),
          _quickActionButton(
            context: context,
            icon: Icons.edit_note,
            label: 'Evento',
            color: AppColors.comunicacion,
            onTap: () => _showCustomEventDialog(context),
            doneIds: const [],
          ),
        ],
      ),
    );
  }

  Widget _quickActionButton({
    required BuildContext context,
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: anyDone ? 0.25 : 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: anyDone
                        ? Border.all(color: Colors.green, width: 1.5)
                        : null,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                if (anyDone)
                  const Positioned(
                    right: -4,
                    top: -4,
                    child:
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color),
            ),
          ],
        ),
      ),
    );
  }

  // -- Bottom sheets --

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
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            )
          : null,
      onTap: () {
        Navigator.pop(sheetContext);
        onLogAction(id, logText);
      },
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
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
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
        onLogAction('rhythm', logText);
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAirwayOptions(BuildContext context) {
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

  void _showPulseOptions(BuildContext context) {
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
                  const Text(
                    'Comprobar pulso',
                    style: TextStyle(
                      fontSize: 18,
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
                        style: TextStyle(
                          fontSize: 12,
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
                      onLogAction('pulse_check', 'Comprobacion de pulso');
                      onLogAction('rosc',
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
                      onLogAction('pulse_check', 'Comprobacion de pulso');
                      onLogAction('no_pulse', 'Sin pulso - continuar RCP');
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

  void _showDeaOptions(BuildContext context) {
    final isSvb = mode == RcpMode.svb;
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
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    )
                  : null,
              onTap: () {
                Navigator.pop(ctx);
                if (isSvb) {
                  _showDeaAnalysis(context);
                } else {
                  _showRhythmAnalysis(context);
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

  void _showDeaAnalysis(BuildContext context) {
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
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      onLogAction('rhythm', 'DEA: Descarga recomendada');
                      onLogAction('shock', 'Descarga DEA administrada');
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
                      onLogAction('rhythm', 'DEA: Descarga no recomendada');
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

  void _showRhythmAnalysis(BuildContext context) {
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
                const Text(
                  'Ritmo identificado',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Analisis #${_countOf('rhythm') + 1}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                const Text(
                  'DESFIBRILABLE',
                  style: TextStyle(
                    fontSize: 13,
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
                const Text(
                  'NO DESFIBRILABLE',
                  style: TextStyle(
                    fontSize: 13,
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
                const Text(
                  'OTROS',
                  style: TextStyle(
                    fontSize: 13,
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

  void _showCustomEventDialog(BuildContext context) {
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
              onLogCustomEvent(value.trim());
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
                onLogCustomEvent(controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }
}
