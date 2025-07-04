import 'dart:math';
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _apiService = ApiService();
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _messageController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final msgs = await _apiService.getMessages();
      setState(() => _messages = msgs);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final user = _usernameController.text;
    final content = _messageController.text;
    final req = CreateMessageRequest(username: user, content: content);
    final err = req.validate();
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err)),
      );
      return;
    }
    try {
      final newMsg = await _apiService.createMessage(req);
      setState(() => _messages.insert(0, newMsg));
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _editMessage(Message msg) async {
    final controller = TextEditingController(text: msg.content);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Content'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) {
      final req = UpdateMessageRequest(content: result);
      try {
        final updated = await _apiService.updateMessage(msg.id, req);
        setState(() {
          final idx = _messages.indexWhere((m) => m.id == msg.id);
          if (idx != -1) _messages[idx] = updated;
        });
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _deleteMessage(Message msg) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _apiService.deleteMessage(msg.id);
        setState(() => _messages.removeWhere((m) => m.id == msg.id));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _showHTTPStatus(int code) async {
    try {
      final info = await _apiService.getHTTPStatus(code);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('HTTP ${info.statusCode}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(info.imageUrl),
              const SizedBox(height: 8),
              Text(info.description),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildMessageTile(Message msg) {
    return ListTile(
      leading: CircleAvatar(child: Text(msg.username[0].toUpperCase())),
      title: Text('${msg.username} • ${msg.timestamp.toLocal()}'.split('.').first),
      subtitle: Text(msg.content),
      trailing: PopupMenuButton<String>(
        onSelected: (v) {
          if (v == 'edit') _editMessage(msg);
          if (v == 'delete') _deleteMessage(msg);
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
      onTap: () {
        final codes = [200, 404, 500, 201, 400];
        final rand = codes[Random().nextInt(codes.length)];
        _showHTTPStatus(rand);
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(labelText: 'Message'),
                ),
              ),
              IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send)),
              PopupMenuButton<int>(
                icon: const Icon(Icons.info_outline),
                onSelected: _showHTTPStatus,
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 100, child: Text('100')),
                  PopupMenuItem(value: 200, child: Text('200')),
                  PopupMenuItem(value: 404, child: Text('404')),
                  PopupMenuItem(value: 500, child: Text('500')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error, size: 48, color: Colors.red),
          const SizedBox(height: 8),
          Text(_error ?? 'Unknown error', style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadMessages,
            child: const Text('Retry'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TODO: Implement ChatScreen'),
      ),
      body: Center(
        child: Text('TODO: Implement chat functionality'),
      ),
    );
  }
}

class HTTPStatusDemo {
  static void showRandomStatus(BuildContext context, ApiService api) {
    final codes = [200, 201, 400, 404, 500];
    final rand = codes[Random().nextInt(codes.length)];
    api.getHTTPStatus(rand).then((info) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('HTTP ${info.statusCode}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(info.imageUrl),
              const SizedBox(height: 8),
              Text(info.description),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      );
    });
  }

  static void showStatusPicker(BuildContext context, ApiService api) {
    const codes = [100, 200, 201, 400, 401, 403, 404, 418, 500, 503];
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Pick HTTP Status'),
        children: codes
            .map((c) => SimpleDialogOption(
                  child: Text(c.toString()),
                  onPressed: () {
                    Navigator.pop(context);
                    api.getHTTPStatus(c).then((info) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('HTTP ${info.statusCode}'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.network(info.imageUrl),
                              const SizedBox(height: 8),
                              Text(info.description),
                            ],
                          ),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close')),
                          ],
                        ),
                      );
                    });
                  },
                ))
            .toList(),
      ),
    );
  }
}