import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../models/task_activity.dart';
import '../../services/auth_service.dart';
import '../../services/task_service.dart';
import '../../utils/constants.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/status_badge.dart';
import '../assignment/assign_task_screen.dart';
import '../sharing/task_sharing_screen.dart';
import 'task_edit_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});
  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _service = TaskService();
  Task? _task;
  List<TaskActivity> _activities = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _task == null;
      _error = null;
    });
    try {
      final t = await _service.get(widget.taskId);
      List<TaskActivity> acts = [];
      try {
        acts = await _service.activities(widget.taskId);
      } catch (_) {}
      if (mounted) {
        setState(() {
          _task = t;
          _activities = acts;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _go(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _load();
  }

  Future<void> _changeStatus(String status) async {
    try {
      await _service.updateStatus(_task!.id, status);
      if (mounted) showSnack(context, 'Đã cập nhật trạng thái');
      _load();
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    }
  }

  Future<void> _delete() async {
    final ok = await confirmDialog(context, 'Xóa công việc',
        'Bạn có chắc muốn xóa "${_task!.title}"? Hành động này không thể hoàn tác.',
        confirmLabel: 'Xóa');
    if (!ok) return;
    try {
      await _service.delete(_task!.id);
      if (!mounted) return;
      showSnack(context, 'Đã xóa công việc');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthService>().user?.id ?? '';
    final t = _task;
    final role = t?.roleFor(uid) ?? 'viewer';
    final canEdit = Task.canEdit(role);
    final isOwner = Task.isOwner(role);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết công việc'),
        actions: [
          if (t != null && canEdit)
            IconButton(
                tooltip: 'Chỉnh sửa',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _go(TaskEditScreen(task: t))),
          if (t != null && isOwner)
            IconButton(tooltip: 'Xóa', icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: _loading
          ? const LoadingView()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : RefreshIndicator(onRefresh: _load, child: _content(t!, canEdit, isOwner)),
    );
  }

  Widget _content(Task t, bool canEdit, bool isOwner) {
    final cs = Theme.of(context).colorScheme;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text(t.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Row(children: [
        StatusBadge(status: t.status),
        const SizedBox(width: 12),
        PriorityBadge(priority: t.priority),
        const Spacer(),
        Chip(
          label: Text(switch (t.roleFor(context.read<AuthService>().user?.id ?? '')) {
            'owner' => 'Người tạo',
            'editor' => 'Được sửa',
            _ => 'Chỉ xem',
          }),
          visualDensity: VisualDensity.compact,
        ),
      ]),
      const SizedBox(height: 16),
      if (t.description.isNotEmpty) Text(t.description),
      const Divider(height: 32),
      _InfoRow(Icons.play_arrow_outlined, 'Bắt đầu', DateFormatter.date(t.startDate)),
      _InfoRow(Icons.event, 'Hạn hoàn thành',
          '${DateFormatter.date(t.dueDate)}${t.isOverdue ? '  (Quá hạn)' : ''}',
          color: t.isOverdue ? cs.error : null),
      _InfoRow(Icons.person_outline, 'Người tạo', t.createdBy?.displayName ?? '—'),
      const SizedBox(height: 8),
      Text('Người được giao', style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 6),
      if (t.assignees.isEmpty)
        Text('Chưa giao cho ai', style: TextStyle(color: cs.outline))
      else
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final u in t.assignees)
            Chip(
              avatar: u.id == t.primaryAssigneeId
                  ? const Icon(Icons.star, size: 16, color: Colors.amber)
                  : CircleAvatar(child: Text(u.initials)),
              label: Text(u.displayName + (u.id == t.primaryAssigneeId ? ' (chính)' : '')),
            ),
        ]),
      if (canEdit) ...[
        const Divider(height: 32),
        Text('Cập nhật trạng thái', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          showSelectedIcon: false,
          segments: [
            for (final e in AppConstants.statuses.entries)
              ButtonSegment(value: e.key, label: Text(e.value, style: const TextStyle(fontSize: 11))),
          ],
          selected: {t.status},
          onSelectionChanged: (s) => _changeStatus(s.first),
        ),
      ],
      if (isOwner) ...[
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.person_add_alt),
              label: const Text('Giao việc'),
              onPressed: () => _go(AssignTaskScreen(task: t)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.share_outlined),
              label: const Text('Chia sẻ'),
              onPressed: () => _go(TaskSharingScreen(task: t)),
            ),
          ),
        ]),
      ],
      const Divider(height: 32),
      Text('Lịch sử hoạt động', style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 4),
      if (_activities.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text('Chưa có hoạt động', style: TextStyle(color: cs.outline)),
        )
      else
        for (final a in _activities)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history, size: 20),
            title: Text('${a.user?.displayName ?? 'Ai đó'} ${a.label}'),
            subtitle: Text(DateFormatter.dateTime(a.createdAt)),
          ),
    ]);
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  const _InfoRow(this.icon, this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Icon(icon, size: 18, color: color ?? Theme.of(context).colorScheme.outline),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
          Expanded(child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w500))),
        ]),
      );
}
