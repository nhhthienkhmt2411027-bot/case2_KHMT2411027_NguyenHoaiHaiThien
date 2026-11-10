import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/statistics_service.dart';
import '../../utils/validators.dart';
import '../../widgets/loading_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _stats = StatisticsService();
  Map<String, dynamic> _tasks = {};
  Map<String, dynamic> _assign = {};
  Map<String, dynamic> _deadline = {};
  bool _loading = true;
  String? _error;

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
      final r = await Future.wait([_stats.tasks(), _stats.assignments(), _stats.deadlines()]);
      if (mounted) {
        setState(() {
          _tasks = r[0];
          _assign = r[1];
          _deadline = r[2];
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _editName() async {
    final auth = context.read<AuthService>();
    final c = TextEditingController(text: auth.user?.fullName);
    final key = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cập nhật họ tên'),
        content: Form(
          key: key,
          child: TextFormField(
            controller: c,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Họ tên'),
            validator: (v) => Validators.required(v, 'Họ tên'),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(
              onPressed: () {
                if (key.currentState!.validate()) Navigator.pop(ctx, true);
              },
              child: const Text('Lưu')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await auth.updateProfile(fullName: c.text);
      if (mounted) showSnack(context, 'Đã cập nhật hồ sơ');
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    }
  }

  Future<void> _changePassword() async {
    final auth = context.read<AuthService>();
    final cur = TextEditingController();
    final next = TextEditingController();
    final conf = TextEditingController();
    final key = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: Form(
          key: key,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
                controller: cur,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu hiện tại'),
                validator: (v) => Validators.required(v, 'Mật khẩu hiện tại')),
            TextFormField(
                controller: next,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
                validator: Validators.password),
            TextFormField(
                controller: conf,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu mới'),
                validator: Validators.confirmPassword(() => next.text)),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(
              onPressed: () {
                if (key.currentState!.validate()) Navigator.pop(ctx, true);
              },
              child: const Text('Đổi')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await auth.changePassword(cur.text, next.text);
      if (mounted) showSnack(context, 'Đã đổi mật khẩu');
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    }
  }

  Future<void> _logout() async {
    final auth = context.read<AuthService>();
    if (await confirmDialog(context, 'Đăng xuất', 'Bạn muốn đăng xuất khỏi tài khoản?',
        confirmLabel: 'Đăng xuất')) {
      await auth.logout();
    }
  }

  int _n(Map<String, dynamic> m, String k) => (m[k] as num?)?.toInt() ?? 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().user;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Cá nhân')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Center(
            child: Column(children: [
              CircleAvatar(
                  radius: 40,
                  child: Text(user?.initials ?? '?', style: const TextStyle(fontSize: 32))),
              const SizedBox(height: 10),
              Text(user?.fullName ?? '', style: Theme.of(context).textTheme.titleLarge),
              Text(user?.email ?? '', style: TextStyle(color: cs.onSurfaceVariant)),
            ]),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(children: [
              ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Cập nhật thông tin'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _editName),
              const Divider(height: 1),
              ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Đổi mật khẩu'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _changePassword),
            ]),
          ),
          const SizedBox(height: 20),
          Text('Thống kê', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (_loading)
            const Padding(padding: EdgeInsets.all(24), child: LoadingView())
          else if (_error != null)
            SizedBox(height: 150, child: ErrorView(message: _error!, onRetry: _load))
          else ...[
            _statRow([
              _Stat('Tổng', _n(_tasks, 'total'), Colors.indigo),
              _Stat('Chưa làm', _n(_tasks, 'todo'), Colors.grey),
              _Stat('Đang làm', _n(_tasks, 'in_progress'), Colors.blue),
              _Stat('Hoàn thành', _n(_tasks, 'completed'), Colors.green),
            ]),
            const SizedBox(height: 8),
            _statRow([
              _Stat('Được giao', _n(_assign, 'assigned'), Colors.purple),
              _Stat('Phụ trách chính', _n(_assign, 'primary'), Colors.deepPurple),
              _Stat('Sắp đến hạn', _n(_deadline, 'upcoming'), Colors.orange),
              _Stat('Quá hạn', _n(_deadline, 'overdue'), Colors.red),
            ]),
          ],
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
            style: OutlinedButton.styleFrom(foregroundColor: cs.error),
          ),
        ]),
      ),
    );
  }

  Widget _statRow(List<_Stat> items) => Row(children: [
        for (final s in items)
          Expanded(
            child: Card(
              color: s.color.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Column(children: [
                  Text('${s.value}',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: s.color)),
                  const SizedBox(height: 2),
                  Text(s.label,
                      textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
                ]),
              ),
            ),
          ),
      ]);
}

class _Stat {
  final String label;
  final int value;
  final Color color;
  _Stat(this.label, this.value, this.color);
}
