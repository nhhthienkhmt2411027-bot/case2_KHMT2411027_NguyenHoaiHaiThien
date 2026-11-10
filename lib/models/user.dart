class User {
  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: (j['_id'] ?? j['id'] ?? '').toString(),
        fullName: (j['fullName'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        avatarUrl: j['avatarUrl'] as String?,
      );

  /// Backend có thể trả về object đã populate hoặc chỉ là id.
  static User? maybe(dynamic v) =>
      v is Map<String, dynamic> ? User.fromJson(v) : null;

  static String idOf(dynamic v) =>
      v is Map ? (v['_id'] ?? v['id'] ?? '').toString() : (v?.toString() ?? '');

  String get displayName => fullName.isNotEmpty ? fullName : email;

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    return parts.last[0].toUpperCase();
  }
}
