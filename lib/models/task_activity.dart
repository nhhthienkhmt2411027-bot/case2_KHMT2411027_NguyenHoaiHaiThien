import '../utils/date_formatter.dart';
import 'user.dart';

class TaskActivity {
  final String id;
  final User? user;
  final String action;
  final Map<String, dynamic> details;
  final DateTime? createdAt;

  const TaskActivity({
    required this.id,
    this.user,
    required this.action,
    this.details = const {},
    this.createdAt,
  });

  factory TaskActivity.fromJson(Map<String, dynamic> j) => TaskActivity(
        id: (j['_id'] ?? j['id'] ?? '').toString(),
        user: User.maybe(j['userId']),
        action: (j['action'] ?? '').toString(),
        details: (j['details'] as Map?)?.cast<String, dynamic>() ?? const {},
        createdAt: DateFormatter.parse(j['createdAt']),
      );

  static const _labels = {
    'create': 'đã tạo công việc',
    'update': 'đã cập nhật công việc',
    'status': 'đã đổi trạng thái',
    'assign': 'đã giao việc',
    'unassign': 'đã hủy giao việc',
    'share': 'đã chia sẻ công việc',
    'unshare': 'đã thu hồi quyền chia sẻ',
  };

  String get label => _labels[action] ?? action;
}
