import 'package:flutter/material.dart';
import '../../models/notification.dart';
import '../../services/notification_service.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/loading_view.dart';
import '../tasks/task_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  /// Gọi khi số thông báo chưa đọc thay đổi để cập nhật badge ở thanh điều hướng.
  final VoidCallback? onChanged;
  const NotificationScreen({super.key, this.onChanged});
  @override
  State<NotificationScreen> createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  final _service = NotificationService();
  List<AppNotification> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    setState(() {
      _loading = _items.isEmpty;
      _error = null;
    });
    try {
      final r = await _service.list();
      if (mounted) setState(() => _items = r);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open(AppNotification n) async {
    if (!n.isRead) {
      try {
        await _service.markRead(n.id);
        widget.onChanged?.call();
      } catch (_) {}
    }
    if (n.taskId != null && mounted) {
      await Navigator.push(
          context, MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: n.taskId!)));
    }
    reload();
  }

  Future<void> _readAll() async {
    try {
      await _service.markAllRead();
      widget.onChanged?.call();
      reload();
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          IconButton(
              tooltip: 'Đánh dấu tất cả đã đọc',
              icon: const Icon(Icons.done_all),
              onPressed: _items.any((n) => !n.isRead) ? _readAll : null),
        ],
      ),
      body: _loading
          ? const LoadingView()
          : _error != null
              ? ErrorView(message: _error!, onRetry: reload)
              : RefreshIndicator(
                  onRefresh: reload,
                  child: _items.isEmpty
                      ? ListView(children: const [
                          SizedBox(height: 120),
                          EmptyView(message: 'Chưa có thông báo', icon: Icons.notifications_none),
                        ])
                      : ListView.separated(
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final n = _items[i];
                            return ListTile(
                              tileColor: n.isRead ? null : cs.primaryContainer.withValues(alpha: 0.35),
                              leading: Icon(
                                n.isRead ? Icons.notifications_none : Icons.notifications_active,
                                color: n.isRead ? cs.outline : cs.primary,
                              ),
                              title: Text(n.title,
                                  style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.w700)),
                              subtitle: Text('${n.message}\n${DateFormatter.dateTime(n.createdAt)}'),
                              isThreeLine: true,
                              onTap: () => _open(n),
                            );
                          },
                        ),
                ),
    );
  }
}
