import 'package:flutter/material.dart';
import 'chat_service.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  final ChatService chatService;
  const ChatScreen({Key? key, required this.chatService}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  StreamSubscription<String>? _sub;
  final List<String> _messages = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.chatService.connect().then((_) {
      _sub = widget.chatService.messageStream.listen(
        (m) => setState(() => _messages.add(m)),
        onError: (e) => setState(() => _error = 'Connection error: ${e.toString()}'),
      );
      setState(() => _loading = false);
    }).catchError((e) {
      setState(() {
        _loading = false;
        _error = 'Connection error: ${e.toString()}';
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    widget.chatService.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _loading = true);
    try {
      await widget.chatService.sendMessage(text);
      _controller.clear();
    } catch (e) {
      setState(() => _error = 'Connection error: ${e.toString()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _messages.isEmpty && _error == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        if (_error != null)
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.red.shade100,
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (_, i) => Text(_messages[i]),
          ),
        ),
        TextField(
          controller: _controller,
          onSubmitted: (_) => _send(),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: _loading ? null : _send,
        ),
      ],
    );
  }
}