import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PriorityBadge extends StatelessWidget {
  final String priority;
  const PriorityBadge({super.key, required this.priority});

  static Color colorOf(String p) => switch (p) {
        'high' => Colors.red,
        'medium' => Colors.orange,
        _ => Colors.teal,
      };

  @override
  Widget build(BuildContext context) {
    final c = colorOf(priority);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.flag, size: 14, color: c),
      const SizedBox(width: 2),
      Text(AppConstants.priorities[priority] ?? priority,
          style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600)),
    ]);
  }
}
