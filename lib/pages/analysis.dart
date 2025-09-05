import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/prefs.dart';
import '../services/live_service.dart';

class AnalysisPage extends StatefulWidget {
  static const route = '/analysis';
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  String _mode = 'FIB';
  String _tf = 'M15';
  bool _live = false;
  double _risk = 1.0;
  double _atr = 1.2;

  final List<double> _prices = [];
  StreamSubscription? _sub;
  double? _lastPrice;

  @override
  void initState() {
    super.initState();
    _load();
    _sub = LiveService.instance.stream.listen((tick) {
      setState(() {
        _lastPrice = tick.price;
        _prices.add(tick.price);
        if (_prices.length > 60) _prices.removeAt(0);
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    _mode = await Prefs.getAnalysisMode();
    _tf = await Prefs.getTimeframe();
    _live = await Prefs.getLiveMode();
    _risk = await Prefs.getRiskPercent();
    _atr = await Prefs.getAtrMult();
    setState(() {});
  }

  List<Widget> _advice() {
    switch (_mode) {
      case 'ICT':
        return const [
          Text('ICT: FVG/BPR + SMT (تجريبي).'),
          Text('دخول بعد اغلاق تأكيدي، وقف عند سوينغ قريب × ATR 1.0.'),
        ];
      case 'SMC':
        return const [
          Text('SMC: BOS/CHOCH مع HH/HL أو LH/LL.'),
          Text('POI عودة + وقف خلفه × ATR 1.2.'),
        ];
      case 'EMA_RSI':
        return const [
          Text('EMA(50/200) لتحديد الاتجاه + RSI للتشبع.'),
          Text('دخول مع تقاطع EMA والخروج عند الحياد.'),
        ];
      case 'BREAKOUT':
        return const [
          Text('Breakout: كسر نطاق تذبذب/قمة-قاع.'),
          Text('دخول على إعادة الاختبار + وقف داخل النطاق.'),
        ];
      case 'MEAN':
        return const [
          Text('Mean Reversion: انحراف سعري بعيد عن المتوسط.'),
          Text('ادخل عودة للمتوسط، إدارة R:1 ثم تعقب.'),
        ];
      case 'VWAP':
        return const [
          Text('VWAP: تداول حول متوسط الحجم المرجح.'),
          Text('دخول عند ارتداد إلى VWAP مع تأكيد حجم.'),
        ];
      case 'ICHIMOKU':
        return const [
          Text('Ichimoku: Kumo break + Tenkan/Kijun cross.'),
          Text('فلترة مع Chikou فوق/تحت السعر.'),
        ];
      case 'RSI_DIV':
        return const [
          Text('RSI Divergence: اختلاف السعر والمؤشر.'),
          Text('تأكيد بكسر ترند RSI والدخول بإدارة مخاطر ضيقة.'),
        ];
      default:
        return const [
          Text('Fibonacci: مناطق 0.5–0.62 للدخول.'),
          Text('أهداف R:1 → R:1.5 → R:2.'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? imagePath = ModalRoute.of(context)!.settings.arguments as String?;
    return Scaffold(
      appBar: AppBar(title: const Text('تحليل الشارت')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagePath != null)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(File(imagePath), fit: BoxFit.contain),
                ),
              )
            else
              const Text('لم يتم اختيار صورة.'),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('النظام: $_mode • الإطار: $_tf • ${_live ? "مباشر" : "يدوي"}'),
                const Spacer(),
                if (_lastPrice != null) Text('السعر: ${_lastPrice!.toStringAsFixed(5)}'),
              ],
            ),
            Text('المخاطرة: ${_risk.toStringAsFixed(1)}% • ATR× ${_atr.toStringAsFixed(1)}'),
            const SizedBox(height: 8),
            SizedBox(height: 60, child: CustomPaint(painter: _Sparkline(_prices))),
            const SizedBox(height: 8),
            const Text('التوصيات (تجريبية):', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._advice(),
          ],
        ),
      ),
    );
  }
}

class _Sparkline extends CustomPainter {
  final List<double> data;
  _Sparkline(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final minV = data.reduce((a,b)=>a<b?a:b);
    final maxV = data.reduce((a,b)=>a>b?a:b);
    final range = (maxV - minV) == 0 ? 1 : (maxV - minV);
    final path = Path();
    for (int i=0;i<data.length;i++){
      final denom = (data.length-1) <= 0 ? 1 : (data.length-1);
      final x = size.width * i/denom;
      final y = size.height - ((data[i]-minV)/range) * size.height;
      if (i==0) path.moveTo(x,y); else path.lineTo(x,y);
    }
    final p = Paint()..strokeWidth=2..style=PaintingStyle.stroke;
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _Sparkline oldDelegate)=> oldDelegate.data!=data;
}