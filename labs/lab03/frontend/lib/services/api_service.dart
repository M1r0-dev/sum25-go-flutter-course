import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);
  late final http.Client _client;

  ApiService() {
    _client = http.Client();
  }

  void dispose() {
    _client.close();
  }

  Map<String, String> _getHeaders() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<List<Message>> getMessages() async {
    throw UnimplementedError('getMessages is not implemented');
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    throw UnimplementedError('createMessage is not implemented');
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    throw UnimplementedError('updateMessage is not implemented');
  }

  Future<void> deleteMessage(int id) async {
    throw UnimplementedError('deleteMessage is not implemented');
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    throw UnimplementedError('getHTTPStatus is not implemented');
  }

  Future<Map<String, dynamic>> healthCheck() async {
    throw UnimplementedError('healthCheck is not implemented');
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message);
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message);
}
