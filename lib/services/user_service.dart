import '../models/user.dart';
import 'api_client.dart';

class UserService {
  final _api = ApiClient.instance;

  Future<List<User>> search(String q) async {
    final d = await _api.get('/users/search', query: {'q': q.trim()});
    return ApiClient.asList(d, 'users').map(User.fromJson).toList();
  }

  Future<User> getById(String id) async =>
      User.fromJson(await _api.get('/users/$id') as Map<String, dynamic>);
}
