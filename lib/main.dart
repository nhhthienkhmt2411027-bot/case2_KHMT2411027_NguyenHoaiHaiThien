import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthService();
  await auth.init(); // khôi phục phiên đăng nhập từ token đã lưu
  runApp(ChangeNotifierProvider.value(value: auth, child: const TaskManagerApp()));
}
