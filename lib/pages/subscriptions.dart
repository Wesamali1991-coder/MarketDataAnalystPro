import 'package:flutter/material.dart';

class SubscriptionsPage extends StatelessWidget {
  static const route = '/subscriptions';
  const SubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الاشتراك (تجريبي)')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('قريباً: ربط الاشتراكات والإشعارات المتقدمة.'),
      ),
    );
  }
}