import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:remixicon/remixicon.dart';

import '../theme/app_colors.dart';

class AppHeader extends StatefulWidget {
  const AppHeader({super.key, this.onSettingsTap});

  final VoidCallback? onSettingsTap;

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  bool _isSettingsPressed = false;

  @override
  Widget build(BuildContext context) {
    final Color iconBorder = _isSettingsPressed
        ? AppColors.primary300.withOpacity(0.6)
        : AppColors.primary200.withOpacity(0.6);
    final Color iconColor =
        _isSettingsPressed ? AppColors.primary600 : AppColors.primary400;
    final Color iconBackground =
        _isSettingsPressed ? AppColors.primary100 : AppColors.primary50;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          const Text(
            'Kkomi',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              letterSpacing: -0.5,
              color: AppColors.neutral800,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTapDown: (_) => setState(() => _isSettingsPressed = true),
            onTapUp: (_) => setState(() => _isSettingsPressed = false),
            onTapCancel: () => setState(() => _isSettingsPressed = false),
            onTap: widget.onSettingsTap,
            child:
                    AnimatedContainer(
                      duration: 120.ms,
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconBackground,
                        shape: BoxShape.circle,
                        border: Border.all(color: iconBorder, width: 1),
                      ),
                      child: Icon(
                        RemixIcons.settings_3_fill,
                        size: 20,
                        color: iconColor,
                      ),
                    )
                    .animate(target: _isSettingsPressed ? 1 : 0)
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(0.88, 0.88),
                      duration: 100.ms,
                      curve: Curves.easeOut,
                    ),
          ),
        ],
      ),
    );
  }
}
