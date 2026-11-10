import '../models/task.dart';
import '../models/task_activity.dart';
import 'api_client.dart';

class TaskService {
  final _api = ApiClient.instance;

  Future<List<Task>> list({
    String scope = '',
    String? status,
    String? priority,
    String? q,
    String sortBy = 'dueDate',
    String order = 'asc',
  }) async {
    final query = <String, String>{
      if (scope.isNotEmpty) 'scope': scope,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
      'sortBy': sortBy,
      'order': order,
    };
    final d = await _api.get('/tasks', query: query);
    return ApiClient.asList(d, 'tasks').map(Task.fromJson).toList();
  }

  Future<Task> get(String id) async =>
      Task.fromJson(await _api.get('/tasks/$id') as Map<String, dynamic>);

  Future<Task> create(Map<String, dynamic> data) async =>
      Task.fromJson(await _api.post('/tasks', body: data) as Map<String, dynamic>);

  Future<Task> update(String id, Map<String, dynamic> data) async =>
      Task.fromJson(await _api.put('/tasks/$id', body: data) as Map<String, dynamic>);

  Future<void> delete(String id) => _api.delete('/tasks/$id');

  Future<void> updateStatus(String id, String status) =>
      _api.patch('/tasks/$id/status', body: {'status': status});

  Future<List<TaskActivity>> activities(String id) async {
    final d = await _api.get('/tasks/$id/activities');
    return ApiClient.asList(d, 'activities').map(TaskActivity.fromJson).toList();
  }

  // ---- Giao việc ----
  Future<void> assign(String id, List<String> userIds) =>
      _api.post('/tasks/$id/assignees', body: {'userIds': userIds});

  Future<void> setPrimary(String id, String userId) =>
      _api.patch('/tasks/$id/assignees/$userId', body: {'isPrimary': true});

  Future<void> unassign(String id, String userId) =>
      _api.delete('/tasks/$id/assignees/$userId');
}
