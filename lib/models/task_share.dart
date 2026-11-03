import 'user.dart';

enum SharePermission { view, edit }

class TaskShare {
  final String id;
  final String taskId;
  final User sharedWithUser;
  final SharePermission permission;

  TaskShare({
    required this.id,
    required this.taskId,
    required this.sharedWithUser,
    required this.permission,
  });

  factory TaskShare.fromJson(Map<String, dynamic> json) {
    return TaskShare(
      id: json['id'] ?? json['_id'] ?? '',
      taskId: json['taskId'] ?? json['task_id'] ?? '',
      sharedWithUser: User.fromJson(json['sharedWithUser'] ?? json['shared_with_user']),
      permission: json['permission'] == 'edit'
          ? SharePermission.edit
          : SharePermission.view,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'sharedWithUser': sharedWithUser.toJson(),
      'permission': permission.name,
    };
  }
}