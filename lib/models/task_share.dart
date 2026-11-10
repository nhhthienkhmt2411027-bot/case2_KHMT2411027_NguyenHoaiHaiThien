import '../utils/date_formatter.dart';
import 'user.dart';

class TaskShare {
  final String id;
  final String taskId;
  final User user;
  final String permission; // viewer | editor
  final DateTime? createdAt;

  const TaskShare({
    required this.id,
    required this.taskId,
    required this.user,
    required this.permission,
    this.createdAt,
  });

  factory TaskShare.fromJson(Map<String, dynamic> j) => TaskShare(
        id: (j['_id'] ?? j['id'] ?? '').toString(),
        taskId: User.idOf(j['taskId']),
        user: User.maybe(j['userId']) ??
            User(id: User.idOf(j['userId']), fullName: '', email: ''),
        permission: (j['permission'] ?? 'viewer').toString(),
        createdAt: DateFormatter.parse(j['createdAt']),
      );
}
