import 'package:flutter/material.dart';

import '../../core/data/settings_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_logger.dart';

/// Settings bottom sheet for home screen
class SettingsBottomSheet extends StatelessWidget {
  const SettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                '설정',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral800,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.neutral500),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Native Viewer Option
          ValueListenableBuilder<bool>(
            valueListenable: SettingsStore.instance.preferNativeViewer,
            builder: (context, preferNative, _) {
              return InkWell(
                onTap: () async {
                  final newValue = !preferNative;
                  await SettingsStore.instance.setPreferNativeViewer(newValue);
                  appLogger.i(
                    '[SETTINGS_SHEET] Toggled preferNativeViewer: $newValue',
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '시스템 뷰어 선호',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.neutral800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Office 문서를 시스템 앱으로 열기 (iOS/Android)',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Checkbox(
                        value: preferNative,
                        onChanged: (value) async {
                          if (value != null) {
                            await SettingsStore.instance.setPreferNativeViewer(
                              value,
                            );
                            appLogger.i(
                              '[SETTINGS_SHEET] Toggled preferNativeViewer: $value',
                            );
                          }
                        },
                        activeColor: AppColors.primary600,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// Show settings bottom sheet
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const SettingsBottomSheet(),
    );
  }
}
