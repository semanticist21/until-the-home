import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_logger.dart';
import '../utils/date_utils.dart' as date_utils;

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
    final today = date_utils.DateUtils.getTodayString();
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

    try {
      final lastUsedDate = date_utils.DateUtils.parseDate(lastUsedDateStr);
      final todayDate = date_utils.DateUtils.parseDate(today);
      final daysDiff = date_utils.DateUtils.daysBetween(
        lastUsedDate,
        todayDate,
      );

      if (daysDiff == 1) {
        // 하루 차이 (어제 사용) → 연속 사용 +1
        currentStreak.value += 1;
        await _save(today, currentStreak.value);
        appLogger.i(
          '[UsageStreakStore] Consecutive day → streak=${currentStreak.value}',
        );
      } else if (daysDiff > 1) {
        // 2일 이상 차이 → 리셋
        currentStreak.value = 1;
        await _save(today, 1);
        appLogger.i(
          '[UsageStreakStore] Reset streak (gap=$daysDiff days) → streak=1',
        );
      } else if (daysDiff < 0) {
        // 시스템 시간이 과거로 변경된 경우 → 날짜만 업데이트, streak 유지
        await _save(today, currentStreak.value);
        appLogger.w(
          '[UsageStreakStore] Time went backwards (diff=$daysDiff) → keeping streak=${currentStreak.value}',
        );
      }
    } catch (e) {
      // 날짜 파싱 실패 시 안전하게 리셋
      appLogger.e('[UsageStreakStore] Date parsing error', error: e);
      currentStreak.value = 1;
      await _save(today, 1);
    }
  }

  /// 날짜와 streak 저장
  Future<void> _save(String dateStr, int streak) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUsedDateKey, dateStr);
    await prefs.setInt(_currentStreakKey, streak);
  }
}
