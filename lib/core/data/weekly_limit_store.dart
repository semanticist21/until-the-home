import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_logger.dart';
import '../utils/date_utils.dart' as date_utils;

/// 주간 사용량 한도 관리
class WeeklyLimitStore {
  WeeklyLimitStore._();

  static final WeeklyLimitStore instance = WeeklyLimitStore._();

  static const _weekStartDateKey = 'week_start_date_v1';
  static const _currentUsageKey = 'current_usage_v1';
  static const _weeklyLimitKey = 'weekly_limit_v1';

  /// 주간 한도 (기본값: 200)
  static const defaultWeeklyLimit = 200;

  /// 현재 사용량
  final ValueNotifier<int> currentUsage = ValueNotifier(0);

  /// 주간 한도
  final ValueNotifier<int> weeklyLimit = ValueNotifier(defaultWeeklyLimit);

  /// 주 시작일 (월요일)
  DateTime? _weekStartDate;

  bool _loaded = false;

  /// 저장된 데이터 로드
  Future<void> load() async {
    if (_loaded) {
      return;
    }
    _loaded = true;

    final prefs = await SharedPreferences.getInstance();
    final weekStartDateStr = prefs.getString(_weekStartDateKey);
    final usage = prefs.getInt(_currentUsageKey) ?? 0;
    final limit = prefs.getInt(_weeklyLimitKey) ?? defaultWeeklyLimit;

    if (weekStartDateStr != null) {
      _weekStartDate = DateTime.parse(weekStartDateStr);
    }

    currentUsage.value = usage;
    weeklyLimit.value = limit;

    appLogger.d(
      '[WeeklyLimitStore] Loaded: weekStart=$weekStartDateStr, usage=$usage, limit=$limit',
    );
  }

  /// 앱 시작 시 호출: 주간 리셋 체크
  Future<void> checkWeeklyReset() async {
    await load();

    final today = DateTime.now();
    final thisWeekStart = date_utils.DateUtils.getMondayOfWeek(today);

    if (_weekStartDate == null) {
      // 첫 실행
      _weekStartDate = thisWeekStart;
      currentUsage.value = 0;
      await _save();
      appLogger.i('[WeeklyLimitStore] First launch → reset to 0');
      return;
    }

    if (_weekStartDate!.isBefore(thisWeekStart)) {
      // 새로운 주 시작 → 리셋
      _weekStartDate = thisWeekStart;
      currentUsage.value = 0;
      await _save();
      appLogger.i('[WeeklyLimitStore] New week started → reset to 0');
    }
  }

  /// 사용량 추가
  Future<void> addUsage(int amount) async {
    await load();
    currentUsage.value += amount;
    await _save();
    appLogger.d(
      '[WeeklyLimitStore] Added usage: $amount → total=${currentUsage.value}',
    );
  }

  /// 남은 사용량
  int get remainingUsage => weeklyLimit.value - currentUsage.value;

  /// 사용 비율 (0.0 ~ 1.0)
  double get usageRatio {
    if (weeklyLimit.value == 0) return 0.0;
    return (currentUsage.value / weeklyLimit.value).clamp(0.0, 1.0);
  }

  /// 다음 리셋까지 남은 일수 (0 이상 보장)
  int get daysUntilReset {
    if (_weekStartDate == null) return 0;
    final nextWeekStart = _weekStartDate!.add(const Duration(days: 7));
    final today = DateTime.now();
    final days = nextWeekStart.difference(today).inDays;
    return days < 0 ? 0 : days;
  }

  /// 주간 한도 변경
  Future<void> setWeeklyLimit(int newLimit) async {
    await load();
    weeklyLimit.value = newLimit;
    await _save();
    appLogger.i('[WeeklyLimitStore] Weekly limit changed: $newLimit');
  }

  /// 데이터 저장
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    if (_weekStartDate != null) {
      await prefs.setString(
        _weekStartDateKey,
        _weekStartDate!.toIso8601String(),
      );
    }
    await prefs.setInt(_currentUsageKey, currentUsage.value);
    await prefs.setInt(_weeklyLimitKey, weeklyLimit.value);
  }
}
