import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/task_card.dart';
import 'task_create_screen.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _service = TaskService();
  final _search = TextEditingController();

  List<Task> _tasks = [];
  bool _loading = true;
  String? _error;

  String _scope = '';
  String? _status;
  String? _priority;
  String _sortBy = 'dueDate';
  bool _asc = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await _service.list(
        scope: _scope,
        status: _status,
        priority: _priority,
        q: _search.text,
        sortBy: _sortBy,
        order: _asc ? 'asc' : 'desc',
      );
      if (mounted) setState(() => _tasks = r);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open(Task t) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: t.id)));
    _load();
  }

  Future<void> _create() async {
    final ok = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (_) => const TaskCreateScreen()));
    if (ok == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Công việc'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sắp xếp',
            onSelected: (v) {
              setState(() => _sortBy = v);
              _load();
            },
            itemBuilder: (_) => [
              for (final e in AppConstants.sortOptions.entries)
                CheckedPopupMenuItem(value: e.key, checked: _sortBy == e.key, child: Text(e.value)),
            ],
          ),
          IconButton(
            tooltip: _asc ? 'Tăng dần' : 'Giảm dần',
            icon: Icon(_asc ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () {
              setState(() => _asc = !_asc);
              _load();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _load(),
            decoration: InputDecoration(
              hintText: 'Tìm theo tên công việc',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
              contentPadding: EdgeInsets.zero,
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _search.clear();
                        _load();
                      }),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              for (final e in AppConstants.scopes.entries)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(e.value),
                    selected: _scope == e.key,
                    onSelected: (_) {
                      setState(() => _scope = e.key);
                      _load();
                    },
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            Expanded(
              child: _FilterDropdown(
                label: 'Trạng thái',
                value: _status,
                options: AppConstants.statuses,
                onChanged: (v) {
                  setState(() => _status = v);
                  _load();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _FilterDropdown(
                label: 'Ưu tiên',
                value: _priority,
                options: AppConstants.priorities,
                onChanged: (v) {
                  setState(() => _priority = v);
                  _load();
                },
              ),
            ),
          ]),
        ),
        const SizedBox(height: 4),
        Expanded(child: _body()),
      ]),
    );
  }

  Widget _body() {
    if (_loading) return const LoadingView();
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    return RefreshIndicator(
      onRefresh: _load,
      child: _tasks.isEmpty
          ? ListView(children: const [
              SizedBox(height: 120),
              EmptyView(message: 'Chưa có công việc nào', icon: Icons.checklist),
            ])
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: _tasks.length,
              itemBuilder: (_, i) => TaskCard(task: _tasks[i], onTap: () => _open(_tasks[i])),
            ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final Map<String, String> options;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String?>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem<String?>(value: null, child: Text('Tất cả')),
          for (final e in options.entries)
            DropdownMenuItem<String?>(value: e.key, child: Text(e.value)),
        ],
        onChanged: onChanged,
      );
}
