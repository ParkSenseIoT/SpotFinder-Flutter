import 'package:flutter/material.dart';

import '../../domain/entities/emergency_status_entity.dart';

/// Bright-red banner that appears at the top of the dashboard whenever the
/// parking lot has an active emergency (gas or smoke detected).
class EmergencyBanner extends StatelessWidget {
  const EmergencyBanner({super.key, required this.status});
  final EmergencyStatusEntity status;

  @override
  Widget build(BuildContext context) {
    if (!status.isActive) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.type == 'SMOKE'
                      ? 'Smoke detected in the parking lot'
                      : 'Gas leak detected',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status.sensorLocation == null
                      ? 'Evacuate the area immediately. All barriers have been opened.'
                      : '${status.sensorLocation}. Evacuate immediately.',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
