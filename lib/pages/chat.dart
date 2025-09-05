import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  static const route = '/chat';
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الدردشة (تجريبية)')),
      body: const Center(child: Text('هذه شاشة دردشة تجريبية (بدون باك-إند).')),
    );
  }
}