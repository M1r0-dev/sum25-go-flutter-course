import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // TODO: Add ApiService, state fields, controllers, etc.

  @override
  void initState() {
    super.initState();
    // TODO: load data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TODO: Implement ChatScreen'),
      ),
      body: const Center(
        child: Text('TODO: Implement chat functionality'),
      ),
    );
  }
}
