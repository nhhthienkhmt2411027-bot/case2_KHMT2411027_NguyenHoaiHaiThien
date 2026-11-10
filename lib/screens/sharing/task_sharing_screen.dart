import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/task_share.dart';
import '../../models/user.dart';
import '../../services/task_share_service.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/user_selector.dart';

class TaskSharingScreen extends StatefulWidget {
  final Task task;
  const TaskSharingScreen({super.key, required this.task});
  @override
  State<TaskSharingScreen> createState() => _TaskSharingScreenState();
}

class _TaskSharingScreenState extends State<TaskSharingScreen> {
  final _service = TaskShareService();
  List<TaskShare> _shares = [];
  bool _loading = true;
  String? _error;

  List<User> _toAdd = [];
  String _newPermission = 'viewer';
  bool _adding = false;
  int _selectorKey = 0; // đổi key để reset UserSelector sau khi thêm

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await _service.list(widget.task.id);
      if (mounted) setState(() => _shares = r);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _add() async {
    if (_toAdd.isEmpty) return;
    setState(() => _adding = true);
    try {
      await _service.add(widget.task.id, _toAdd.map((u) => u.id).toList(), _newPermission);
      if (!mounted) return;
      showSnack(context, 'Đã chia sẻ công việc');
      setState(() {
        _toAdd = [];
        _selectorKey++;
      });
      _load();
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  Future<void> _changePermission(TaskShare s, String p) async {
    try {
      await _service.updatePermission(widget.task.id, s.id, p);
      if (mounted) showSnack(context, 'Đã đổi quyền');
      _load();
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    }
  }

  Future<void> _revoke(TaskShare s) async {
    final ok = await confirmDialog(context, 'Thu hồi quyền',
        'Thu hồi quyền truy cập của ${s.user.displayName}?',
        confirmLabel: 'Thu hồi');
    if (!ok) return;
    try {
      await _service.revoke(widget.task.id, s.id);
      if (mounted) showSnack(context, 'Đã thu hồi quyền');
      _load();
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final existing = _shares.map((s) => s.user.id).toSet();
    return Scaffold(
      appBar: AppBar(title: const Text('Chia sẻ & phân quyền')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(widget.task.title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        Text('Thêm người được chia sẻ', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        UserSelector(
          key: ValueKey(_selectorKey),
          excludeIds: {...existing, if (widget.task.createdBy != null) widget.task.createdBy!.id},
          onChanged: (l) => setState(() => _toAdd = [...l]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _newPermission,
              decoration: const InputDecoration(labelText: 'Quyền', isDense: true, border: OutlineInputBorder()),
              items: [
                for (final e in AppConstants.permissions.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: (v) => setState(() => _newPermission = v!),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: (_adding || _toAdd.isEmpty) ? null : _add,
            icon: const Icon(Icons.share),
            label: const Text('Chia sẻ'),
          ),
        ]),
        const Divider(height: 32),
        Text('Đang được chia sẻ (${_shares.length})', style: Theme.of(context).textTheme.titleSmall),
        if (_loading)
          const Padding(padding: EdgeInsets.all(24), child: LoadingView())
        else if (_error != null)
          SizedBox(height: 160, child: ErrorView(message: _error!, onRetry: _load))
        else if (_shares.isEmpty)
          const Padding(padding: EdgeInsets.all(24), child: EmptyView(message: 'Chưa chia sẻ cho ai'))
        else
          for (final s in _shares)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Text(s.user.initials)),
              title: Text(s.user.displayName),
              subtitle: Text(s.user.email),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                DropdownButton<String>(
                  value: s.permission,
                  underline: const SizedBox(),
                  items: [
                    for (final e in AppConstants.permissions.entries)
                      DropdownMenuItem(value: e.key, child: Text(e.value)),
                  ],
                  onChanged: (v) {
                    if (v != null && v != s.permission) _changePermission(s, v);
                  },
                ),
                IconButton(
                  tooltip: 'Thu hồi',
                  icon: const Icon(Icons.person_remove_outlined),
                  onPressed: () => _revoke(s),
                ),
              ]),
            ),
      ]),
    );
  }
}
