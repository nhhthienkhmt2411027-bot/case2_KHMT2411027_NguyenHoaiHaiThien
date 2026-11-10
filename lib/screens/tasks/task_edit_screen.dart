import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/task_form.dart';

class TaskEditScreen extends StatelessWidget {
  final Task task;
  const TaskEditScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa công việc')),
      body: TaskForm(
        initial: task,
        submitLabel: 'Lưu thay đổi',
        onSubmit: (data) async {
          final nav = Navigator.of(context);
          await TaskService().update(task.id, data);
          if (context.mounted) showSnack(context, 'Đã cập nhật công việc');
          nav.pop(true);
        },
      ),
    );
  }
}
