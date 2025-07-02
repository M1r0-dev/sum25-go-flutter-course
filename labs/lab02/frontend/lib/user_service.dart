import 'dart:async';

class UserService {
  bool fail = false;

  Future<Map<String, String>> fetchUser() async {
    if (fail) throw Exception('Fetch failed');
    await Future.delayed(const Duration(milliseconds: 10));
    return {'name': 'Alice', 'email': 'alice@example.com'};
  }
}