// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/api_service.dart';
import 'models/message.dart';
import 'models/message.dart'; 
import 'screens/chat_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider<ChatProvider>(
          create: (ctx) => ChatProvider(ctx.read<ApiService>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 03 REST API Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(secondary: Colors.orange),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
          ),
        ),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}


class ChatProvider extends ChangeNotifier {
  final ApiService _apiService;

  ChatProvider(this._apiService) {
    loadMessages();
  }

  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _messages = await _apiService.getMessages();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createMessage(String username, String content) async {
    final req = CreateMessageRequest(username: username, content: content);
    final validation = req.validate();
    if (validation != null) {
      _error = validation;
      notifyListeners();
      return;
    }

    try {
      final msg = await _apiService.createMessage(req);
      _messages.insert(0, msg);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> updateMessage(int id, String newContent) async {
    final req = UpdateMessageRequest(content: newContent);
    final validation = req.validate();
    if (validation != null) {
      _error = validation;
      notifyListeners();
      return;
    }

    try {
      final updated = await _apiService.updateMessage(id, req);
      final i = _messages.indexWhere((m) => m.id == id);
      if (i != -1) _messages[i] = updated;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> deleteMessage(int id) async {
    try {
      await _apiService.deleteMessage(id);
      _messages.removeWhere((m) => m.id == id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> refreshMessages() async {
    _messages.clear();
    await loadMessages();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
