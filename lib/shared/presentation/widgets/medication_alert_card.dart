import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/domain/models/medication_protocol.dart';

class MedicationAlertCard extends StatelessWidget {
  final MedicationTracker tracker;
  final VoidCallback onAdminister;

  const MedicationAlertCard({
    required this.tracker,
    required this.onAdminister,
    super.key,
  });

  Color _backgroundForUrgency(double urgency) {
    if (urgency < 0.5) return Colors.green.shade50;
    if (urgency < 1.0) return Colors.yellow.shade50;
    return Colors.red.shade50;
  }

  Color _borderForUrgency(double urgency) {
    if (urgency < 0.5) return Colors.green;
    if (urgency < 1.0) return Colors.orange;
    return Colors.red;
  }

  String _formatDuration(Duration d) {
    final mm = d.inMinutes.toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final medication = tracker.medication;
    final isMaxReached = tracker.isMaxReached;

    if (isMaxReached) {
      return _buildGreyedOutCard(medication);
    }

    final urgency = tracker.urgencyRatio;
    final bg = _backgroundForUrgency(urgency);
    final border = _borderForUrgency(urgency);
    final timeSince = tracker.timeSinceLastDose;

    return Card(
      color: bg,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: border, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    medication.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    medication.dose,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (timeSince != null) ...[
                        Icon(Icons.timer_outlined, size: 14, color: border),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(timeSince),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                            color: border,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Text(
                        'Dosis: ${tracker.dosesGiven}'
                        '${medication.maxDoses != null ? '/${medication.maxDoses}' : ''}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onAdminister,
              style: ElevatedButton.styleFrom(
                backgroundColor: border,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Administrar', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreyedOutCard(Medication medication) {
    return Card(
      color: Colors.grey.shade200,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    medication.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    medication.dose,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Text(
              'Maximo alcanzado',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
