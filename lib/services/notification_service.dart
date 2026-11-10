import '../models/notification.dart';
import 'api_client.dart';

class NotificationService {
  final _api = ApiClient.instance;

  Future<List<AppNotification>> list() async {
    final d = await _api.get('/notifications');
    return ApiClient.asList(d, 'notifications')
        .map(AppNotification.fromJson)
        .toList();
  }

  Future<int> unreadCount() async {
    final d = await _api.get('/notifications/unread-count');
    if (d is Map) return (d['count'] ?? d['unread'] ?? 0) as int;
    return d is int ? d : 0;
  }

  Future<void> markRead(String id) => _api.patch('/notifications/$id/read');
  Future<void> markAllRead() => _api.patch('/notifications/read-all');
}
