import 'package:flutter/material.dart';
import '../utils/constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  static Color colorOf(String s) => switch (s) {
        'completed' => Colors.green,
        'in_progress' => Colors.blue,
        _ => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    final c = colorOf(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(AppConstants.statuses[status] ?? status,
          style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
