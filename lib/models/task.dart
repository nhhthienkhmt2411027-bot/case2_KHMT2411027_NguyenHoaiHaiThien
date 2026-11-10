import '../utils/date_formatter.dart';
import 'user.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final User? createdBy;
  final List<User> assignees;
  final String? primaryAssigneeId;
  final DateTime? startDate;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final String priority; // low | medium | high
  final String status; // todo | in_progress | completed

  /// owner | editor | viewer — backend nên trả về quyền của người đang gọi.
  final String? permission;

  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.createdBy,
    this.assignees = const [],
    this.primaryAssigneeId,
    this.startDate,
    this.dueDate,
    this.createdAt,
    this.priority = 'medium',
    this.status = 'todo',
    this.permission,
  });

  factory Task.fromJson(Map<String, dynamic> j) {
    final raw = (j['assigneeIds'] as List?) ?? const [];
    return Task(
      id: (j['_id'] ?? j['id'] ?? '').toString(),
      title: (j['title'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      createdBy: User.maybe(j['createdBy']),
      assignees: raw
          .map((e) => e is Map<String, dynamic>
              ? User.fromJson(e)
              : User(id: e.toString(), fullName: '', email: ''))
          .toList(),
      primaryAssigneeId:
          j['primaryAssigneeId'] == null ? null : User.idOf(j['primaryAssigneeId']),
      startDate: DateFormatter.parse(j['startDate']),
      dueDate: DateFormatter.parse(j['dueDate']),
      createdAt: DateFormatter.parse(j['createdAt']),
      priority: (j['priority'] ?? 'medium').toString(),
      status: (j['status'] ?? 'todo').toString(),
      permission: (j['permission'] ?? j['myPermission'])?.toString(),
    );
  }

  bool get isOverdue =>
      dueDate != null && status != 'completed' && dueDate!.isBefore(DateTime.now());

  /// Quyền của người dùng hiện tại. Chỉ dùng để ẩn/hiện nút;
  /// việc kiểm tra quyền thật sự nằm ở backend.
  String roleFor(String uid) {
    if (permission != null) return permission!;
    if (createdBy?.id == uid) return 'owner';
    if (assignees.any((u) => u.id == uid)) return 'editor';
    return 'viewer';
  }

  static bool canEdit(String role) => role == 'owner' || role == 'editor';
  static bool isOwner(String role) => role == 'owner';
}
