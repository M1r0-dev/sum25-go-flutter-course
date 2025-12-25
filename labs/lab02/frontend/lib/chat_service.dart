import 'dart:async';

class ChatService {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  bool failConnect = false;
  bool failSend = false;

  Future<void> connect() async {
    if (failConnect) throw Exception('Connect failed');
    await Future.delayed(const Duration(milliseconds: 10));
  }

  Future<void> sendMessage(String msg) async {
    if (failSend) throw Exception('Send failed');
    await Future.delayed(const Duration(milliseconds: 10));
    _controller.add(msg);
  }

  Stream<String> get messageStream => _controller.stream;

  void dispose() {
    _controller.close();
  }
}