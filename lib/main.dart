import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'core/data/usage_streak_store.dart';
import 'core/theme/app_theme.dart';
import 'screens/home/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  pdfrxFlutterInitialize(dismissPdfiumWasmWarnings: true);
  timeago.setLocaleMessages('ko', timeago.KoMessages());

  // 연속 사용일 업데이트
  await UsageStreakStore.instance.updateStreak();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.light;

    return MaterialApp(
      title: 'kkomi',
      locale: const Locale('en', 'US'),
      localizationsDelegates: FLocalizations.localizationsDelegates,
      supportedLocales: FLocalizations.supportedLocales,
      // ignore: experimental_member_use
      theme: theme.toApproximateMaterialTheme(),
      builder: (context, child) => FTheme(data: theme, child: child!),
      home: const HomeScreen(),
    );
  }
}
