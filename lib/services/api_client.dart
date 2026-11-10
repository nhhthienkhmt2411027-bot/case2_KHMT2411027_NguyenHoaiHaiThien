import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Client HTTP dùng chung: gắn JWT, giải mã JSON, chuẩn hóa lỗi.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const _tokenKey = 'auth_token';
  String? _token;
  String? get token => _token;

  /// AuthService gán callback này để tự đăng xuất khi token hết hạn.
  void Function()? onUnauthorized;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove(_tokenKey);
    } else {
      await prefs.setString(_tokenKey, token);
    }
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send('GET', path, query: query);
  Future<dynamic> post(String path, {Object? body}) =>
      _send('POST', path, body: body);
  Future<dynamic> put(String path, {Object? body}) =>
      _send('PUT', path, body: body);
  Future<dynamic> patch(String path, {Object? body}) =>
      _send('PATCH', path, body: body);
  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
  }) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path').replace(
      queryParameters: (query == null || query.isEmpty) ? null : query,
    );
    final req = http.Request(method, uri)
      ..headers['Content-Type'] = 'application/json'
      ..headers['Accept'] = 'application/json';
    if (_token != null) req.headers['Authorization'] = 'Bearer $_token';
    if (body != null) req.body = jsonEncode(body);

    http.Response res;
    try {
      final streamed = await req.send().timeout(const Duration(seconds: 15));
      res = await http.Response.fromStream(streamed);
    } on SocketException {
      throw ApiException('Không thể kết nối máy chủ. Vui lòng kiểm tra mạng.');
    } on TimeoutException {
      throw ApiException('Máy chủ phản hồi quá lâu. Vui lòng thử lại.');
    } on http.ClientException {
      throw ApiException('Không thể kết nối máy chủ.');
    }

    dynamic decoded;
    if (res.body.isNotEmpty) {
      try {
        decoded = jsonDecode(utf8.decode(res.bodyBytes));
      } catch (_) {
        decoded = null;
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (decoded is Map && decoded.containsKey('data')) return decoded['data'];
      return decoded;
    }

    if (res.statusCode == 401 && _token != null) {
      onUnauthorized?.call();
    }
    final msg = decoded is Map
        ? (decoded['message'] ?? decoded['error'])?.toString()
        : null;
    throw ApiException(msg ?? 'Đã xảy ra lỗi (${res.statusCode})', res.statusCode);
  }

  /// Lấy danh sách từ response dạng List hoặc {key: List}.
  static List<Map<String, dynamic>> asList(dynamic d, [String? key]) {
    dynamic l = d;
    if (d is Map && key != null) l = d[key];
    if (l is! List) return [];
    return l.whereType<Map<String, dynamic>>().toList();
  }
}
