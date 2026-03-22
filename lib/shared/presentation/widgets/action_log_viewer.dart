import 'package:flutter/material.dart';
import 'package:emerkit/shared/domain/models/action_log.dart';

class ActionLogViewer extends StatefulWidget {
  final ActionLog actionLog;

  const ActionLogViewer({required this.actionLog, super.key});

  @override
  State<ActionLogViewer> createState() => _ActionLogViewerState();
}

class _ActionLogViewerState extends State<ActionLogViewer> {
  final ScrollController _scrollController = ScrollController();
  int _previousCount = 0;
  bool _userScrolledUp = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    // User is "at the bottom" if within 50px of max
    _userScrolledUp = pos.pixels < pos.maxScrollExtent - 50;
  }

  @override
  void didUpdateWidget(covariant ActionLogViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentCount = widget.actionLog.entries.length;
    if (currentCount > _previousCount && !_userScrolledUp) {
      _previousCount = currentCount;
      _scrollToBottom();
    } else {
      _previousCount = currentCount;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  static Color _categoryColor(String category) {
    switch (category) {
      case 'medicacion':
        return Colors.red;
      case 'compresion':
        return Colors.blue;
      case 'ventilacion':
        return Colors.green;
      case 'evento':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.actionLog.entries;
    final startTime = widget.actionLog.startTime;

    return ListView.builder(
      controller: _scrollController,
      itemCount: entries.length,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final relative = entry.timestamp.difference(startTime);
        final relMm = relative.inMinutes.toString().padLeft(2, '0');
        final relSs = (relative.inSeconds % 60).toString().padLeft(2, '0');
        final clockHh = entry.timestamp.hour.toString().padLeft(2, '0');
        final clockMm = entry.timestamp.minute.toString().padLeft(2, '0');
        final clockSs = entry.timestamp.second.toString().padLeft(2, '0');
        final color = _categoryColor(entry.category);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4, right: 6),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              Text(
                '$clockHh:$clockMm:$clockSs',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '+$relMm:$relSs',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.action,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
