# Market Data Pro — v1.3.1

- 9 أنظمة تحليل: `ICT`, `SMC`, `FIB`, `EMA_RSI`, `BREAKOUT`, `MEAN`, `VWAP`, `ICHIMOKU`, `RSI_DIV`.
- Live Mode يعمل مع مزودات: `DEMO`, `BINANCE` (كريبتو), `ALPHAVANTAGE` و `TWELVEDATA` (فوركس/معادن). 
- إعدادات تحفظ محليًا (SharedPreferences)، ويعرض السعر الحيّ + Sparkline.

## بناء IPA (Codemagic)
- استخدم `codemagic.yaml` المرفق: يضبط `Bundle ID = com.wesam.mda.pro` واسم التطبيق `Market Data Pro` تلقائيًا أثناء البناء.
- يخرج `Runner-unsigned.ipa` جاهز (بدون توقيع).

## ملاحظات
- ضع مفاتيح API في شاشة **الإعدادات** عند اختيار AlphaVantage/TwelveData.
- لمنع التباس الأسماء مع النسخ القديمة، هذا المشروع باسم **mda_pro**.