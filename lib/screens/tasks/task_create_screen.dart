import 'package:flutter/material.dart';
import '../../services/task_service.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/task_form.dart';

class TaskCreateScreen extends StatelessWidget {
  const TaskCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm công việc')),
      body: TaskForm(
        submitLabel: 'Tạo công việc',
        onSubmit: (data) async {
          final nav = Navigator.of(context);
          await TaskService().create(data);
          if (context.mounted) showSnack(context, 'Đã tạo công việc');
          nav.pop(true);
        },
      ),
    );
  }
}
