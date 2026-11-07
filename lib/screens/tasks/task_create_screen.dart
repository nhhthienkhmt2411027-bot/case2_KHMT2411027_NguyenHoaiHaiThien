import 'package:flutter/material.dart';
import '../../services/api_client.dart';

class TaskCreateScreen extends StatefulWidget {
  const TaskCreateScreen({super.key});

  @override
  State<TaskCreateScreen> createState() => _TaskCreateScreenState();
}

class _TaskCreateScreenState extends State<TaskCreateScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _priority = 'medium';
  String _status = 'todo';
  DateTime? _dueDate;
  bool _isLoading = false;

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _handleCreateTask() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên công việc!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final res = await ApiClient.post('/tasks', {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'priority': _priority,
      'status': _status,
      'dueDate': _dueDate?.toIso8601String(),
    });

    setState(() => _isLoading = false);

    if (res.statusCode == 201 || res.statusCode == 200) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo công việc thành công!')),
        );
        Navigator.pop(context, true); // Trả về true để làm mới danh sách
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo công việc thất bại, vui lòng thử lại!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm công việc mới')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tên công việc *', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Mô tả công việc', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _priority,
                      decoration: const InputDecoration(labelText: 'Ưu tiên', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('Thấp')),
                        DropdownMenuItem(value: 'medium', child: Text('Trung bình')),
                        DropdownMenuItem(value: 'high', child: Text('Cao')),
                      ],
                      onChanged: (val) => setState(() => _priority = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(labelText: 'Trạng thái', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'todo', child: Text('Chưa làm')),
                        DropdownMenuItem(value: 'in_progress', child: Text('Đang làm')),
                        DropdownMenuItem(value: 'completed', child: Text('Đã xong')),
                      ],
                      onChanged: (val) => setState(() => _status = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_dueDate == null
                    ? 'Chưa chọn hạn hoàn thành'
                    : 'Hạn: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'),
                trailing: ElevatedButton.icon(
                  onPressed: _selectDueDate,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Chọn ngày'),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _handleCreateTask,
                  child: const Text('Tạo công việc', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}