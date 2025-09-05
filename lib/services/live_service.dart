import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'prefs.dart';

class LiveTick {
  final DateTime t;
  final double price;
  LiveTick(this.t, this.price);
}

class LiveService {
  LiveService._();
  static final instance = LiveService._();

  final _controller = StreamController<LiveTick>.broadcast();
  Timer? _timer;
  String provider = 'DEMO'; // DEMO, BINANCE, ALPHAVANTAGE, TWELVEDATA
  String symbol = 'EURUSD';
  int intervalMs = 3000;
  bool enabled = false;

  String? alphaKey;
  String? twelveKey;

  double _demoBase = 1.1000;
  double _angle = 0.0;

  Stream<LiveTick> get stream => _controller.stream;

  void init() async {
    provider = await Prefs.getProvider();
    symbol = await Prefs.getSymbol();
    intervalMs = await Prefs.getIntervalMs();
    enabled = await Prefs.getLiveMode();
    alphaKey = await Prefs.getAlphaKey();
    twelveKey = await Prefs.getTwelveKey();
    if (enabled) start();
  }

  Future<void> applySettings({
    required String provider,
    required String symbol,
    required int intervalMs,
    required bool enabled,
    String? alphaKey,
    String? twelveKey,
  }) async {
    this.provider = provider;
    this.symbol = symbol.toUpperCase();
    this.intervalMs = intervalMs;
    this.enabled = enabled;
    this.alphaKey = alphaKey ?? this.alphaKey;
    this.twelveKey = twelveKey ?? this.twelveKey;

    await Prefs.setProvider(this.provider);
    await Prefs.setSymbol(this.symbol);
    await Prefs.setIntervalMs(this.intervalMs);
    await Prefs.setLiveMode(this.enabled);
    if (this.alphaKey != null) await Prefs.setAlphaKey(this.alphaKey!);
    if (this.twelveKey != null) await Prefs.setTwelveKey(this.twelveKey!);

    if (enabled) start(); else stop();
  }

  void start() {
    stop();
    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (_) async {
      final price = await _fetchPrice();
      if (price != null) _controller.add(LiveTick(DateTime.now(), price));
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  List<String> _parsePair(String s) {
    s = s.toUpperCase().replaceAll(' ', '');
    if (s.contains('/')) {
      final p = s.split('/');
      if (p.length >= 2) return [p[0], p[1]];
    }
    if (s.length >= 6) {
      return [s.substring(0,3), s.substring(3,6)];
    }
    return [s, 'USD'];
  }

  Future<double?> _fetchPrice() async {
    try {
      if (provider == 'DEMO') {
        _angle += 0.2;
        final noise = Random().nextDouble() * 0.002 - 0.001;
        return _demoBase + sin(_angle) * 0.01 + noise;
      } else if (provider == 'BINANCE') {
        final url = Uri.parse('https://api.binance.com/api/v3/ticker/price?symbol=${symbol.toUpperCase()}');
        final res = await http.get(url).timeout(const Duration(seconds: 8));
        if (res.statusCode == 200) {
          final j = json.decode(res.body);
          return double.tryParse(j['price'].toString());
        }
      } else if (provider == 'ALPHAVANTAGE') {
        if ((alphaKey ?? '').isEmpty) return null;
        final p = _parsePair(symbol);
        final url = Uri.parse('https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=${p[0]}&to_currency=${p[1]}&apikey=$alphaKey');
        final res = await http.get(url).timeout(const Duration(seconds: 10));
        if (res.statusCode == 200) {
          final j = json.decode(res.body);
          final node = j['Realtime Currency Exchange Rate'] ?? j['Realtime Currency Exchange Rate'.toLowerCase()];
          if (node != null) {
            final v = node['5. Exchange Rate'] ?? node['5. exchange rate'];
            return double.tryParse(v.toString());
          }
        }
      } else if (provider == 'TWELVEDATA') {
        if ((twelveKey ?? '').isEmpty) return null;
        final sym = symbol.contains('/') ? symbol : '${symbol[0:3]}/${symbol[3:6]}';
        final url = Uri.parse('https://api.twelvedata.com/price?symbol=$sym&apikey=$twelveKey');
        final res = await http.get(url).timeout(const Duration(seconds: 10));
        if (res.statusCode == 200) {
          final j = json.decode(res.body);
          return double.tryParse(j['price'].toString());
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}