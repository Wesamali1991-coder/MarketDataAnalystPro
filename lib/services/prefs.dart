import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static const _kAnalysisMode = 'analysis_mode'; // ICT, SMC, FIB, EMA_RSI, BREAKOUT, MEAN, VWAP, ICHIMOKU, RSI_DIV
  static const _kLiveMode = 'live_mode';
  static const _kSymbol = 'symbol';
  static const _kProvider = 'provider'; // DEMO, BINANCE, ALPHAVANTAGE, TWELVEDATA
  static const _kIntervalMs = 'interval_ms';
  static const _kRiskPercent = 'risk_percent';
  static const _kAtrMult = 'atr_mult';
  static const _kTimeframe = 'timeframe';
  static const _kNotifications = 'notifications';
  static const _kAlphaKey = 'alpha_key';
  static const _kTwelveKey = 'twelve_key';

  static Future<SharedPreferences> _p() => SharedPreferences.getInstance();

  static Future<String> getAnalysisMode() async =>
      (await _p()).getString(_kAnalysisMode) ?? 'FIB';
  static Future<void> setAnalysisMode(String v) async =>
      (await _p()).setString(_kAnalysisMode, v);

  static Future<bool> getLiveMode() async =>
      (await _p()).getBool(_kLiveMode) ?? false;
  static Future<void> setLiveMode(bool v) async =>
      (await _p()).setBool(_kLiveMode, v);

  static Future<String> getSymbol() async =>
      (await _p()).getString(_kSymbol) ?? 'EURUSD';
  static Future<void> setSymbol(String v) async =>
      (await _p()).setString(_kSymbol, v);

  static Future<String> getProvider() async =>
      (await _p()).getString(_kProvider) ?? 'DEMO';
  static Future<void> setProvider(String v) async =>
      (await _p()).setString(_kProvider, v);

  static Future<int> getIntervalMs() async =>
      (await _p()).getInt(_kIntervalMs) ?? 3000;
  static Future<void> setIntervalMs(int v) async =>
      (await _p()).setInt(_kIntervalMs, v);

  static Future<double> getRiskPercent() async =>
      (await _p()).getDouble(_kRiskPercent) ?? 1.0;
  static Future<void> setRiskPercent(double v) async =>
      (await _p()).setDouble(_kRiskPercent, v);

  static Future<double> getAtrMult() async =>
      (await _p()).getDouble(_kAtrMult) ?? 1.2;
  static Future<void> setAtrMult(double v) async =>
      (await _p()).setDouble(_kAtrMult, v);

  static Future<String> getTimeframe() async =>
      (await _p()).getString(_kTimeframe) ?? 'M15';
  static Future<void> setTimeframe(String v) async =>
      (await _p()).setString(_kTimeframe, v);

  static Future<bool> getNotifications() async =>
      (await _p()).getBool(_kNotifications) ?? false;
  static Future<void> setNotifications(bool v) async =>
      (await _p()).setBool(_kNotifications, v);

  static Future<String?> getAlphaKey() async =>
      (await _p()).getString(_kAlphaKey);
  static Future<void> setAlphaKey(String v) async =>
      (await _p()).setString(_kAlphaKey, v);

  static Future<String?> getTwelveKey() async =>
      (await _p()).getString(_kTwelveKey);
  static Future<void> setTwelveKey(String v) async =>
      (await _p()).setString(_kTwelveKey, v);
}