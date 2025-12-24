import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/app_button.dart';

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
      header: const FHeader(title: Text('Kkomi')),
      child: SafeArea(
        top: false, // Header handles top safe area
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AppButton (Forui)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Primary
              const Text('Primary', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  AppButton(label: 'Button', onPressed: () {}),
                  AppButton(
                    label: 'With Icon',
                    icon: Icons.add,
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Secondary
              const Text('Secondary', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  AppButton(
                    label: 'Convert',
                    variant: AppButtonVariant.secondary,
                    icon: Icons.transform,
                    onPressed: () {},
                  ),
                  AppButton(
                    label: 'Disabled',
                    variant: AppButtonVariant.secondary,
                    onPressed: null,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Outline
              const Text('Outline', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.outline,
                    onPressed: () {},
                  ),
                  AppButton(
                    label: 'Disabled',
                    variant: AppButtonVariant.outline,
                    onPressed: null,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Ghost
              const Text('Ghost', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  AppButton(
                    label: 'Learn More',
                    variant: AppButtonVariant.ghost,
                    onPressed: () {},
                  ),
                  AppButton(
                    label: 'Skip',
                    variant: AppButtonVariant.ghost,
                    icon: Icons.arrow_forward,
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Destructive
              const Text('Destructive', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  AppButton(
                    label: 'Delete',
                    variant: AppButtonVariant.destructive,
                    icon: Icons.delete,
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Full width + loading
              const Text(
                'Full Width & Loading',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              AppButton(
                label: 'Upload File',
                icon: Icons.upload_file,
                isFullWidth: true,
                onPressed: () {},
              ),
              const SizedBox(height: 12),
              const AppButton(
                label: 'Loading...',
                isFullWidth: true,
                isLoading: true,
                onPressed: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
