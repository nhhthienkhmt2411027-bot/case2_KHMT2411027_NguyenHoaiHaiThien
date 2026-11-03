import 'package:flutter/material.dart';
import 'app.dart';

void main() async {
  // Đảm bảo các binding của Flutter đã sẵn sàng trước khi gọi các dịch vụ async
  WidgetsFlutterBinding.ensureInitialized();

  // Chạy ứng dụng
  runApp(const  TaskManagerApp());
}