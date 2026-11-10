import '../utils/date_formatter.dart';
import 'user.dart';

/// Đặt tên AppNotification để không trùng với class Notification của Flutter.
class AppNotification {
  final String id;
  final String? taskId;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    this.taskId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: (j['_id'] ?? j['id'] ?? '').toString(),
        taskId: j['taskId'] == null ? null : User.idOf(j['taskId']),
        type: (j['type'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        message: (j['message'] ?? '').toString(),
        isRead: j['isRead'] == true,
        createdAt: DateFormatter.parse(j['createdAt']),
      );
}
