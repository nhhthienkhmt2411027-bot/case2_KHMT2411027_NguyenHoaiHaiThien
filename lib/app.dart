import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/notifications/notification_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/tasks/task_list_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
      home: Consumer<AuthService>(
        builder: (_, auth, __) =>
            auth.isLoggedIn ? const HomeShell() : const LoginScreen(),
      ),
    );
  }
}

/// Thanh điều hướng dưới: Công việc • Thông báo • Cá nhân.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _notifKey = GlobalKey<NotificationScreenState>();
  final _notifService = NotificationService();
  int _index = 0;
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _refreshUnread();
  }

  Future<void> _refreshUnread() async {
    try {
      final n = await _notifService.unreadCount();
      if (mounted) setState(() => _unread = n);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: [
        const TaskListScreen(),
        NotificationScreen(key: _notifKey, onChanged: _refreshUnread),
        const ProfileScreen(),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() => _index = i);
          if (i == 1) _notifKey.currentState?.reload();
          _refreshUnread();
        },
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.checklist), label: 'Công việc'),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _unread > 0,
              label: Text('$_unread'),
              child: const Icon(Icons.notifications_outlined),
            ),
            label: 'Thông báo',
          ),
          const NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Cá nhân'),
        ],
      ),
    );
  }
}
