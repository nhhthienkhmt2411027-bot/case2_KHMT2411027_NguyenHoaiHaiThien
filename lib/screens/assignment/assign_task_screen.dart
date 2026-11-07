// lib/screens/assignment/assign_task_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/api_client.dart';
import '../../widgets/user_selector.dart';

class AssignTaskScreen extends StatefulWidget {
  final String taskId;

  const AssignTaskScreen({super.key, required this.taskId});

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  List<UserModel> _assignees = [];
  String? _primaryAssigneeId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAssignees();
  }

  Future<void> _loadAssignees() async {
    final res = await ApiClient.get('/tasks/${widget.taskId}/assignees');
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List list = data['assignees'] ?? [];
      setState(() {
        _assignees = list.map((item) => UserModel.fromJson(item)).toList();
        _primaryAssigneeId = data['primaryAssigneeId'];
      });
    }
  }

  Future<void> _saveAssignments() async {
    setState(() => _isLoading = true);
    final res = await ApiClient.post('/tasks/${widget.taskId}/assignees', {
      'assigneeIds': _assignees.map((u) => u.id).toList(),
      'primaryAssigneeId': _primaryAssigneeId,
    });
    setState(() => _isLoading = false);

    if (res.statusCode == 200 || res.statusCode == 201) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật giao việc thành công!')));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giao công việc')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserSelector(
              onUserSelected: (user) {
                if (!_assignees.any((u) => u.id == user.id)) {
                  setState(() {
                    _assignees.add(user);
                    _primaryAssigneeId ??= user.id; // Chọn làm phụ trách chính nếu là người đầu tiên
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            const Text('Danh sách người được giao:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _assignees.length,
                itemBuilder: (context, index) {
                  final user = _assignees[index];
                  final isPrimary = user.id == _primaryAssigneeId;
                  return ListTile(
                    title: Text(user.fullName),
                    subtitle: Text(user.email),
                    leading: Radio<String>(
                      value: user.id,
                      groupValue: _primaryAssigneeId,
                      onChanged: (val) => setState(() => _primaryAssigneeId = val),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isPrimary) const Chip(label: Text('Chính'), backgroundColor: Colors.amberAccent),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _assignees.removeAt(index);
                              if (isPrimary) _primaryAssigneeId = _assignees.isNotEmpty ? _assignees.first.id : null;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(onPressed: _saveAssignments, child: const Text('Lưu thay đổi')),
            ),
          ],
        ),
      ),
    );
  }
}