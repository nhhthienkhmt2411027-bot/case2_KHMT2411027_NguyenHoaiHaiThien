import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/api_client.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late String _currentStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.task.status;
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    final res = await ApiClient.post('/tasks/${widget.task.id}/status', {
      'status': newStatus,
    });
    setState(() => _isUpdating = false);

    if (res.statusCode == 200) {
      setState(() => _currentStatus = newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật trạng thái thành công!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.task.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.task.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.task.description.isEmpty ? 'Không có mô tả.' : widget.task.description,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Độ ưu tiên: ${widget.task.priority.toUpperCase()}'),
                Text('Hạn: ${widget.task.dueDate != null ? "${widget.task.dueDate!.day}/${widget.task.dueDate!.month}/${widget.task.dueDate!.year}" : "Không có"}'),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Cập nhật trạng thái:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _isUpdating
                ? const CircularProgressIndicator()
                : SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'todo', label: Text('Chưa làm')),
                ButtonSegment(value: 'in_progress', label: Text('Đang làm')),
                ButtonSegment(value: 'completed', label: Text('Đã xong')),
              ],
              selected: {_currentStatus},
              onSelectionChanged: (Set<String> newSelection) {
                _updateStatus(newSelection.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}