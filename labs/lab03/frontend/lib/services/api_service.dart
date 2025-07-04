import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);
  final http.Client _client;

  ApiService() : _client = http.Client();
  void dispose() => _client.close();
  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<List<Message>> getMessages() async {
    final uri = Uri.parse('\$baseUrl/messages');
    final res = await _client.get(uri, headers: _headers()).timeout(timeout);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List<dynamic>;
      return data.map((e) => Message.fromJson(e)).toList();
    }
    throw ServerException('Failed to load messages: \${res.statusCode}');
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    final uri = Uri.parse('\$baseUrl/messages');
    final res = await _client.post(
      uri,
      headers: _headers(),
      body: jsonEncode(request.toJson()),
    ).timeout(timeout);
    if (res.statusCode == 201) {
      return Message.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 400) {
      throw ValidationException('Invalid message data');
    }
    throw ServerException('Failed to create message: \${res.statusCode}');
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    final uri = Uri.parse('\$baseUrl/messages/\$id');
    final res = await _client.put(
      uri,
      headers: _headers(),
      body: jsonEncode(request.toJson()),
    ).timeout(timeout);
    if (res.statusCode == 200) {
      return Message.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 400) {
      throw ValidationException('Invalid update data');
    }
    throw ServerException('Failed to update message: \${res.statusCode}');
  }

  Future<void> deleteMessage(int id) async {
    final uri = Uri.parse('\$baseUrl/messages/\$id');
    final res = await _client.delete(uri, headers: _headers()).timeout(timeout);
    if (res.statusCode != 204) {
      throw ServerException('Failed to delete message: \${res.statusCode}');
    }
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    final uri = Uri.parse('\$baseUrl/status/\$statusCode');
    final res = await _client.get(uri, headers: _headers()).timeout(timeout);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return HTTPStatusResponse(
      statusCode: res.statusCode,
      imageUrl: body['imageUrl'] as String,
      description: body['description'] as String,
    );
  }

  Future<Map<String, dynamic>> healthCheck() async {
    final uri = Uri.parse('\$baseUrl/health');
    final res = await _client.get(uri, headers: _headers()).timeout(timeout);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw ServerException('Health check failed');
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override String toString() => 'ApiException: \$message';
}

class NetworkException extends ApiException { NetworkException(String m): super(m); }
class ServerException extends ApiException { ServerException(String m): super(m); }
class ValidationException extends ApiException { ValidationException(String m): super(m); }