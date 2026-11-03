import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/tasks/task_list_screen.dart';

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,

      // Cấu hình Giao diện (Theme)
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),

      // Định tuyến màn hình ban đầu (Ví dụ: Chuyển thẳng đến màn hình chính hoặc Đăng nhập)
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/tasks': (context) => const TaskListScreen(),
      },
    );
  }
}