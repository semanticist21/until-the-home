import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:remixicon/remixicon.dart';

import '../../core/theme/app_colors.dart';

class Header extends StatefulWidget {
  const Header({super.key, this.onSettingsTap});

  final VoidCallback? onSettingsTap;

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  bool _isSettingsPressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        children: [
          const Text(
            '홈',
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
                Icon(
                      RemixIcons.settings_3_fill,
                      size: 22,
                      color: Colors.grey.shade500,
                    )
                    .animate(target: _isSettingsPressed ? 1 : 0)
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(0.9, 0.9),
                      duration: 100.ms,
                      curve: Curves.easeOut,
                    ),
          ),
        ],
      ),
    );
  }
}
