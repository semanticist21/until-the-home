import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:remixicon/remixicon.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';

void main() {
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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(
        suffixes: [
          FHeaderAction(
            icon: const Icon(
              RemixIcons.settings_3_fill,
              color: AppColors.primary500,
            ),
            onPress: () {},
          ),
        ],
      ),
      child: const SizedBox.shrink(),
    );
  }
}
