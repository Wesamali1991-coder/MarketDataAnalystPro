import 'package:flutter/material.dart';
import '../services/prefs.dart';
import 'analysis.dart';
import 'subscriptions.dart';
import 'chat.dart';
import 'settings.dart';
import 'package:file_picker/file_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _mode = '...';
  String _tf = '...';
  bool _live = false;
  String _provider = '...';
  String _symbol = '...';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final m = await Prefs.getAnalysisMode();
    final t = await Prefs.getTimeframe();
    final l = await Prefs.getLiveMode();
    final p = await Prefs.getProvider();
    final s = await Prefs.getSymbol();
    if (mounted) setState(() { _mode = m; _tf = t; _live = l; _provider = p; _symbol = s; });
  }

  Future<void> _pickChart() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);
    if (res != null && res.files.single.path != null && mounted) {
      Navigator.pushNamed(context, AnalysisPage.route, arguments: res.files.single.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Market Data Pro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('مرحباً 👋', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('النظام: $_mode • الإطار: $_tf'),
            Text('Live: ${_live ? "تشغيل" : "إيقاف"} • مزود: ${_provider} • الرمز: $_symbol'),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              FilledButton.icon(onPressed: _pickChart, icon: const Icon(Icons.upload), label: const Text('رفع صورة الشارت')),
              OutlinedButton.icon(onPressed: () => Navigator.pushNamed(context, SettingsPage.route).then((_) => _load()),
                icon: const Icon(Icons.settings_outlined), label: const Text('الإعدادات')),
              OutlinedButton.icon(onPressed: () => Navigator.pushNamed(context, SubscriptionsPage.route),
                icon: const Icon(Icons.workspace_premium), label: const Text('الاشتراك')),
              OutlinedButton.icon(onPressed: () => Navigator.pushNamed(context, ChatPage.route),
                icon: const Icon(Icons.chat_bubble_outline), label: const Text('الدردشة')),
            ]),
            const Spacer(),
            const Text('v1.3.1 • Pro build', style: TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}