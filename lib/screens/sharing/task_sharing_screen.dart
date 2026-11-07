// lib/screens/sharing/task_sharing_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/api_client.dart';
import '../../widgets/user_selector.dart';

class TaskShareItem {
  final String shareId;
  final UserModel user;
  String permission; // 'viewer' hoặc 'editor'

  TaskShareItem({required this.shareId, required this.user, required this.permission});
}

class TaskSharingScreen extends StatefulWidget {
  final String taskId;

  const TaskSharingScreen({super.key, required this.taskId});

  @override
  State<TaskSharingScreen> createState() => _TaskSharingScreenState();
}

class _TaskSharingScreenState extends State<TaskSharingScreen> {
  List<TaskShareItem> _shares = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadShares();
  }

  Future<void> _loadShares() async {
    final res = await ApiClient.get('/tasks/${widget.taskId}/shares');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      setState(() {
        _shares = data.map((item) => TaskShareItem(
          shareId: item['_id'],
          user: UserModel.fromJson(item['userId']),
          permission: item['permission'] ?? 'viewer',
        )).toList();
      });
    }
  }

  Future<void> _addShare(UserModel user, String permission) async {
    final res = await ApiClient.post('/tasks/${widget.taskId}/shares', {
      'userId': user.id,
      'permission': permission,
    });
    if (res.statusCode == 200 || res.statusCode == 201) {
      _loadShares();
    }
  }

  Future<void> _updatePermission(String shareId, String newPermission) async {
    await ApiClient.post('/tasks/${widget.taskId}/shares/$shareId', {
      'permission': newPermission,
    });
    _loadShares();
  }

  Future<void> _removeShare(String shareId) async {
    // API xóa/thu hồi quyền chia sẻ
    await ApiClient.post('/tasks/${widget.taskId}/shares/$shareId/delete', {});
    _loadShares();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chia sẻ & Phân quyền')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            UserSelector(
              onUserSelected: (user) => _addShare(user, 'viewer'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _shares.length,
                itemBuilder: (context, index) {
                  final item = _shares[index];
                  return ListTile(
                    title: Text(item.user.fullName),
                    subtitle: Text(item.user.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButton<String>(
                          value: item.permission,
                          items: const [
                            DropdownMenuItem(value: 'viewer', child: Text('Viewer (Xem)')),
                            DropdownMenuItem(value: 'editor', child: Text('Editor (Sửa)')),
                          ],
                          onChanged: (val) {
                            if (val != null) _updatePermission(item.shareId, val);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _removeShare(item.shareId),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}