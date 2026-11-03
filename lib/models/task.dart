import 'user.dart';

enum TaskStatus { todo, inProgress, done }
enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;
  final User? assignee;
  final String creatorId;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.assignee,
    required this.creatorId,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: _parseStatus(json['status']),
      priority: _parsePriority(json['priority']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      assignee: json['assignee'] != null ? User.fromJson(json['assignee']) : null,
      creatorId: json['creatorId'] ?? json['creator_id'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'dueDate': dueDate?.toIso8601String(),
      'assignee': assignee?.toJson(),
      'creatorId': creatorId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static TaskStatus _parseStatus(String? statusStr) {
    switch (statusStr) {
      case 'inProgress':
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'done':
        return TaskStatus.done;
      default:
        return TaskStatus.todo;
    }
  }

  static TaskPriority _parsePriority(String? priorityStr) {
    switch (priorityStr) {
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }
}