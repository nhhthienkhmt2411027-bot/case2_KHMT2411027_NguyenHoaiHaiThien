import 'api_client.dart';

/// Kỳ vọng backend trả về:
///  /statistics/tasks       -> {total, todo, in_progress, completed}
///  /statistics/assignments -> {assigned, primary}
///  /statistics/deadlines   -> {upcoming, overdue}
class StatisticsService {
  final _api = ApiClient.instance;

  Future<Map<String, dynamic>> _map(String path) async {
    final d = await _api.get(path);
    return d is Map<String, dynamic> ? d : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> tasks() => _map('/statistics/tasks');
  Future<Map<String, dynamic>> assignments() => _map('/statistics/assignments');
  Future<Map<String, dynamic>> deadlines() => _map('/statistics/deadlines');
}
