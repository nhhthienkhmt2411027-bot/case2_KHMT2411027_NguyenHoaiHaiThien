import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/date_formatter.dart';
import 'priority_badge.dart';
import 'status_badge.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  const TaskCard({super.key, required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ),
              StatusBadge(status: task.status),
            ]),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: cs.onSurfaceVariant)),
            ],
            const SizedBox(height: 10),
            Row(children: [
              PriorityBadge(priority: task.priority),
              const Spacer(),
              Icon(Icons.event,
                  size: 14, color: task.isOverdue ? cs.error : cs.outline),
              const SizedBox(width: 4),
              Text(DateFormatter.date(task.dueDate),
                  style: TextStyle(
                      fontSize: 12,
                      color: task.isOverdue ? cs.error : cs.outline,
                      fontWeight: task.isOverdue ? FontWeight.w600 : null)),
              if (task.isOverdue)
                Text(' • Quá hạn',
                    style: TextStyle(fontSize: 12, color: cs.error)),
            ]),
          ]),
        ),
      ),
    );
  }
}
