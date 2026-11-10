import 'package:flutter/foundation.dart';

import '../models/user.dart';
import 'api_client.dart';

class AuthService extends ChangeNotifier {
  final _api = ApiClient.instance;
  User? _user;
  User? get user => _user;
  bool get isLoggedIn => _user != null;

  /// Gọi 1 lần khi mở app: khôi phục phiên đăng nhập từ token đã lưu.
  Future<void> init() async {
    _api.onUnauthorized = _handleExpired;
    await _api.loadToken();
    if (_api.token == null) return;
    try {
      _user = User.fromJson(await _api.get('/auth/me') as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.statusCode == 401) await _api.saveToken(null);
      // Lỗi mạng: giữ token, người dùng thử lại sau.
    }
  }

  void _handleExpired() {
    _api.saveToken(null);
    _user = null;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final d = await _api.post('/auth/login',
        body: {'email': email.trim(), 'password': password}) as Map<String, dynamic>;
    await _api.saveToken(d['token'] as String);
    _user = User.fromJson(d['user'] as Map<String, dynamic>);
    notifyListeners();
  }

  Future<void> register(String fullName, String email, String password) async {
    final d = await _api.post('/auth/register', body: {
      'fullName': fullName.trim(),
      'email': email.trim(),
      'password': password,
    }) as Map<String, dynamic>;
    await _api.saveToken(d['token'] as String);
    _user = User.fromJson(d['user'] as Map<String, dynamic>);
    notifyListeners();
  }

  Future<void> logout() async {
    await _api.saveToken(null);
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile({required String fullName}) async {
    final d = await _api.put('/auth/me', body: {'fullName': fullName.trim()});
    _user = User.fromJson(d as Map<String, dynamic>);
    notifyListeners();
  }

  Future<void> changePassword(String current, String next) async {
    await _api.put('/auth/change-password',
        body: {'currentPassword': current, 'newPassword': next});
  }
}
