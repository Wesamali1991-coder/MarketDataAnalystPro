import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'pages/analysis.dart';
import 'pages/subscriptions.dart';
import 'pages/chat.dart';
import 'pages/settings.dart';
import 'services/live_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LiveService.instance.init();
  runApp(const MDAProApp());
}

class MDAProApp extends StatelessWidget {
  const MDAProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Market Data Pro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        AnalysisPage.route: (_) => const AnalysisPage(),
        SubscriptionsPage.route: (_) => const SubscriptionsPage(),
        ChatPage.route: (_) => const ChatPage(),
        SettingsPage.route: (_) => const SettingsPage(),
      },
    );
  }
}