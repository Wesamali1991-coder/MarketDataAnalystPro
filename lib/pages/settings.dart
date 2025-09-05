import 'package:flutter/material.dart';
import '../services/prefs.dart';
import '../services/live_service.dart';

class SettingsPage extends StatefulWidget {
  static const route = '/settings';
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _modes = const ['ICT', 'SMC', 'FIB', 'EMA_RSI', 'BREAKOUT', 'MEAN', 'VWAP', 'ICHIMOKU', 'RSI_DIV'];
  final _tfs = const ['M5', 'M15', 'H1', 'H4'];
  final _providers = const ['DEMO', 'BINANCE', 'ALPHAVANTAGE', 'TWELVEDATA'];

  String _mode = 'FIB';
  String _tf = 'M15';
  bool _live = false;
  bool _noti = false;
  double _risk = 1.0;
  double _atr = 1.2;
  String _provider = 'DEMO';
  String _symbol = 'EURUSD';
  double _interval = 3; // seconds
  String _alphaKey = '';
  String _twelveKey = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _mode = await Prefs.getAnalysisMode();
    _tf = await Prefs.getTimeframe();
    _live = await Prefs.getLiveMode();
    _noti = await Prefs.getNotifications();
    _risk = await Prefs.getRiskPercent();
    _atr = await Prefs.getAtrMult();
    _provider = await Prefs.getProvider();
    _symbol = await Prefs.getSymbol();
    _interval = (await Prefs.getIntervalMs()) / 1000.0;
    _alphaKey = (await Prefs.getAlphaKey()) ?? '';
    _twelveKey = (await Prefs.getTwelveKey()) ?? '';
    setState(() {});
  }

  Future<void> _save() async {
    await Prefs.setAnalysisMode(_mode);
    await Prefs.setTimeframe(_tf);
    await Prefs.setNotifications(_noti);
    await Prefs.setRiskPercent(_risk);
    await Prefs.setAtrMult(_atr);
    await Prefs.setProvider(_provider);
    await Prefs.setSymbol(_symbol);
    await Prefs.setIntervalMs((_interval * 1000).round());
    await Prefs.setLiveMode(_live);
    if (_alphaKey.isNotEmpty) await Prefs.setAlphaKey(_alphaKey);
    if (_twelveKey.isNotEmpty) await Prefs.setTwelveKey(_twelveKey);

    await LiveService.instance.applySettings(
      provider: _provider,
      symbol: _symbol,
      intervalMs: (_interval * 1000).round(),
      enabled: _live,
      alphaKey: _alphaKey.isEmpty ? null : _alphaKey,
      twelveKey: _twelveKey.isEmpty ? null : _twelveKey,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ الإعدادات')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isForex = _provider == 'ALPHAVANTAGE' || _provider == 'TWELVEDATA';
    final hint = _provider == 'BINANCE' ? 'مثال: BTCUSDT' : (isForex ? 'مثال: EURUSD أو EUR/USD أو XAUUSD' : 'مثال: EURUSD');
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('نظام التحليل', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButtonFormField<String>(
            value: _mode,
            items: _modes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _mode = v ?? _mode),
          ),
          const SizedBox(height: 16),
          const Text('الإطار الزمني الافتراضي'),
          DropdownButtonFormField<String>(
            value: _tf,
            items: _tfs.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _tf = v ?? _tf),
          ),
          const SizedBox(height: 24),
          const Text('وضع مباشر (Live Mode)', style: TextStyle(fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('تفعيل Live Mode'),
            value: _live,
            onChanged: (v) => setState(() => _live = v),
          ),
          DropdownButtonFormField<String>(
            value: _provider,
            decoration: const InputDecoration(labelText: 'مزود البيانات'),
            items: _providers.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _provider = v ?? _provider),
          ),
          TextFormField(
            initialValue: _symbol,
            decoration: InputDecoration(labelText: 'الرمز', helperText: hint),
            onChanged: (v) => _symbol = v.toUpperCase(),
          ),
          if (_provider == 'ALPHAVANTAGE')
            TextFormField(
              initialValue: _alphaKey,
              decoration: const InputDecoration(labelText: 'Alpha Vantage API Key'),
              onChanged: (v) => _alphaKey = v.trim(),
            ),
          if (_provider == 'TWELVEDATA')
            TextFormField(
              initialValue: _twelveKey,
              decoration: const InputDecoration(labelText: 'TwelveData API Key'),
              onChanged: (v) => _twelveKey = v.trim(),
            ),
          ListTile(
            title: Text('فاصل التحديث: ${_interval.toStringAsFixed(0)} ثانية'),
            subtitle: Slider(min: 1, max: 15, divisions: 14, value: _interval, onChanged: (v) => setState(() => _interval = v)),
          ),
          const Divider(),
          const Text('إدارة المخاطر', style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            title: Text('نسبة المخاطرة: ${_risk.toStringAsFixed(1)} %'),
            subtitle: Slider(value: _risk, min: 0.5, max: 5, divisions: 9, label: _risk.toStringAsFixed(1),
              onChanged: (v) => setState(() => _risk = v)),
          ),
          ListTile(
            title: Text('ATR multiplier: ${_atr.toStringAsFixed(1)}'),
            subtitle: Slider(value: _atr, min: 0.5, max: 3, divisions: 10, label: _atr.toStringAsFixed(1),
              onChanged: (v) => setState(() => _atr = v)),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save_outlined), label: const Text('حفظ')),
        ],
      ),
    );
  }
}