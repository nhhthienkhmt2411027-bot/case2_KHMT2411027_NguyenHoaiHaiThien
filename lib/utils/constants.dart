class AppConstants {
  /// Android emulator: 10.0.2.2 trỏ về localhost của máy tính.
  /// Đổi bằng: flutter run --dart-define=API_URL=http://192.168.1.10:3000/api
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  static const Map<String, String> statuses = {
    'todo': 'Chưa thực hiện',
    'in_progress': 'Đang thực hiện',
    'completed': 'Đã hoàn thành',
  };

  static const Map<String, String> priorities = {
    'low': 'Thấp',
    'medium': 'Trung bình',
    'high': 'Cao',
  };

  static const Map<String, String> permissions = {
    'viewer': 'Chỉ xem',
    'editor': 'Chỉnh sửa',
  };

  static const Map<String, String> scopes = {
    '': 'Tất cả',
    'created': 'Của tôi',
    'assigned': 'Được giao',
    'shared': 'Được chia sẻ',
  };

  static const Map<String, String> sortOptions = {
    'dueDate': 'Hạn hoàn thành',
    'priority': 'Mức độ ưu tiên',
    'createdAt': 'Thời gian tạo',
  };
}
