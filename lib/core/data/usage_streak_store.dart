import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_logger.dart';

/// 앱 연속 사용일 관리
class UsageStreakStore {
  UsageStreakStore._();

  static final UsageStreakStore instance = UsageStreakStore._();

  static const _lastUsedDateKey = 'last_used_date_v1';
  static const _currentStreakKey = 'current_streak_v1';

  /// 현재 연속 사용일
  final ValueNotifier<int> currentStreak = ValueNotifier(0);

  bool _loaded = false;

  /// 저장된 데이터 로드
  Future<void> load() async {
    if (_loaded) {
      return;
    }
    _loaded = true;

    final prefs = await SharedPreferences.getInstance();
    final lastUsedDateStr = prefs.getString(_lastUsedDateKey);
    final streak = prefs.getInt(_currentStreakKey) ?? 0;

    appLogger.d(
      '[UsageStreakStore] Loaded: lastUsedDate=$lastUsedDateStr, streak=$streak',
    );

    currentStreak.value = streak;
  }

  /// 앱 시작 시 호출: 연속 사용일 업데이트
  Future<void> updateStreak() async {
    await load();

    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayString();
    final lastUsedDateStr = prefs.getString(_lastUsedDateKey);

    appLogger.d(
      '[UsageStreakStore] updateStreak: today=$today, lastUsed=$lastUsedDateStr',
    );

    if (lastUsedDateStr == null) {
      // 첫 실행
      currentStreak.value = 1;
      await _save(today, 1);
      appLogger.i('[UsageStreakStore] First launch → streak=1');
      return;
    }

    if (lastUsedDateStr == today) {
      // 오늘 이미 기록됨
      appLogger.d('[UsageStreakStore] Already updated today');
      return;
    }

    final lastUsedDate = DateTime.parse(lastUsedDateStr);
    final todayDate = DateTime.parse(today);
    final daysDiff = todayDate.difference(lastUsedDate).inDays;

    if (daysDiff == 1) {
      // 하루 차이 (어제 사용) → 연속 사용 +1
      currentStreak.value += 1;
      await _save(today, currentStreak.value);
      appLogger.i(
        '[UsageStreakStore] Consecutive day → streak=${currentStreak.value}',
      );
    } else {
      // 2일 이상 차이 → 리셋
      currentStreak.value = 1;
      await _save(today, 1);
      appLogger.i(
        '[UsageStreakStore] Reset streak (gap=$daysDiff days) → streak=1',
      );
    }
  }

  /// 날짜와 streak 저장
  Future<void> _save(String dateStr, int streak) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUsedDateKey, dateStr);
    await prefs.setInt(_currentStreakKey, streak);
  }

  /// 오늘 날짜 문자열 (YYYY-MM-DD)
  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
