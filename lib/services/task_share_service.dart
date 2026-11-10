import '../models/task_share.dart';
import 'api_client.dart';

class TaskShareService {
  final _api = ApiClient.instance;

  Future<List<TaskShare>> list(String taskId) async {
    final d = await _api.get('/tasks/$taskId/shares');
    return ApiClient.asList(d, 'shares').map(TaskShare.fromJson).toList();
  }

  Future<void> add(String taskId, List<String> userIds, String permission) =>
      _api.post('/tasks/$taskId/shares', body: {
        'shares': [
          for (final id in userIds) {'userId': id, 'permission': permission}
        ],
      });

  Future<void> updatePermission(String taskId, String shareId, String permission) =>
      _api.patch('/tasks/$taskId/shares/$shareId', body: {'permission': permission});

  Future<void> revoke(String taskId, String shareId) =>
      _api.delete('/tasks/$taskId/shares/$shareId');
}
