import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/user.dart';
import '../../services/task_service.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/user_selector.dart';

class AssignTaskScreen extends StatefulWidget {
  final Task task;
  const AssignTaskScreen({super.key, required this.task});
  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  final _service = TaskService();
  late List<User> _selected = [...widget.task.assignees];
  late String? _primaryId = widget.task.primaryAssigneeId;
  bool _saving = false;

  Future<void> _submit() async {
    final oldIds = widget.task.assignees.map((u) => u.id).toSet();
    final newIds = _selected.map((u) => u.id).toSet();
    final added = newIds.difference(oldIds).toList();
    final removed = oldIds.difference(newIds);

    final ok = await confirmDialog(
      context,
      'Xác nhận giao việc',
      'Giao cho ${newIds.length} người. Người được thêm sẽ nhận thông báo và email.',
    );
    if (!ok) return;

    setState(() => _saving = true);
    try {
      for (final id in removed) {
        await _service.unassign(widget.task.id, id);
      }
      if (added.isNotEmpty) await _service.assign(widget.task.id, added);
      final primary = newIds.contains(_primaryId) ? _primaryId : null;
      if (primary != null && primary != widget.task.primaryAssigneeId) {
        await _service.setPrimary(widget.task.id, primary);
      }
      if (!mounted) return;
      showSnack(context, 'Đã cập nhật người được giao');
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giao công việc')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(widget.task.title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        UserSelector(
          initialSelected: widget.task.assignees,
          onChanged: (l) => setState(() => _selected = [...l]),
        ),
        if (_selected.isNotEmpty) ...[
          const Divider(height: 32),
          Text('Chọn người phụ trách chính', style: Theme.of(context).textTheme.titleSmall),
          RadioGroup<String>(
            groupValue: _primaryId,
            onChanged: (v) => setState(() => _primaryId = v),
            child: Column(children: [
              for (final u in _selected)
                RadioListTile<String>(
                  value: u.id,
                  title: Text(u.displayName),
                  subtitle: Text(u.email),
                  contentPadding: EdgeInsets.zero,
                ),
            ]),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Xác nhận giao việc'),
        ),
      ]),
    );
  }
}
