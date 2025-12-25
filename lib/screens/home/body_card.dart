import 'package:flutter/material.dart';

import '../../core/widgets/app_progress.dart';

class BodyCard extends StatelessWidget {
  const BodyCard({super.key});

  Color _getProgressColor(double value) {
    if (value >= 0.9) {
      return const Color(0xFFE53935); // Red
    } else if (value >= 0.75) {
      return const Color(0xFFFFA726); // Orange/Yellow
    }
    return const Color(0xFF4CAF50); // Green (default)
  }

  @override
  Widget build(BuildContext context) {
    const currentUsage = 150;
    const weeklyLimit = 200;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly limit row with count-up animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: currentUsage.toDouble()),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, child) {
                final progressValue = animatedValue / weeklyLimit;

                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/icons/usage_empty.webp',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Text(
                                  '주간 한도',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700,
                                    height: 1,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '3일 후 초기화',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade400,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${animatedValue.toInt()} / $weeklyLimit',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 28),
                      child: AppProgress(
                        value: progressValue,
                        color: _getProgressColor(progressValue),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            // Stats row - 2 columns
            Row(
              children: [
                // Streak days
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 3),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      final intValue = value.toInt();
                      final display = intValue > 999 ? '999+' : '$intValue';
                      return _StatColumn(
                        icon: 'assets/images/icons/calendar_bun_empty.webp',
                        label: '연속 사용',
                        value: '$display일',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Pages viewed
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 127),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      final intValue = value.toInt();
                      final display = intValue > 999 ? '999+' : '$intValue';
                      return _StatColumn(
                        icon: 'assets/images/icons/document_open_empty.webp',
                        label: '이번 주 열람',
                        value: '$display페이지',
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.icon,
    required this.label,
    required this.value,
  });

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.asset(icon, width: 24, height: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
