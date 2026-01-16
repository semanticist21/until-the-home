import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/data/history_tips.dart';
import '../../core/data/usage_streak_store.dart';
import '../../core/data/weekly_limit_store.dart';
import '../../core/data/weekly_pages_store.dart';
import '../../core/widgets/app_progress.dart';

class BodyCard extends StatefulWidget {
  const BodyCard({super.key});

  @override
  State<BodyCard> createState() => _BodyCardState();
}

class _BodyCardState extends State<BodyCard> {
  late final HistoryTip _tip;

  @override
  void initState() {
    super.initState();
    _tip = historyTips[Random().nextInt(historyTips.length)];
  }

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
            // Weekly usage row with count-up animation
            ValueListenableBuilder<int>(
              valueListenable: WeeklyLimitStore.instance.currentUsage,
              builder: (context, currentUsage, child) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: currentUsage.toDouble()),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedValue, child) {
                    // 그래프 기준: 100 (100 이상은 100%로 표시)
                    final progressValue = min(animatedValue / 100.0, 1.0);
                    final daysUntilReset =
                        WeeklyLimitStore.instance.daysUntilReset;

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
                                      '주간 열람',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade700,
                                        height: 1,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '$daysUntilReset일 후 초기화',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade400,
                                        height: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${animatedValue.toInt()}',
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
                );
              },
            ),
            const SizedBox(height: 20),
            // Stats row - 2 columns
            Row(
              children: [
                // Streak days
                Expanded(
                  child: ValueListenableBuilder<int>(
                    valueListenable: UsageStreakStore.instance.currentStreak,
                    builder: (context, streakCount, child) {
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: streakCount.toDouble()),
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
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Pages viewed
                Expanded(
                  child: ValueListenableBuilder<int>(
                    valueListenable: WeeklyPagesStore.instance.currentPages,
                    builder: (context, currentPages, child) {
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: currentPages.toDouble()),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          final intValue = value.toInt();
                          final display = intValue > 999 ? '999+' : '$intValue';
                          return _StatColumn(
                            icon:
                                'assets/images/icons/document_open_empty.webp',
                            label: '이번 주 페이지',
                            value: '${display}p',
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Today's tip row
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Image.asset(
                      'assets/images/icons/light_empty.webp',
                      width: 20,
                      height: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _tip.fact,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
