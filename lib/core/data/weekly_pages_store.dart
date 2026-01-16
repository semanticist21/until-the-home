import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_logger.dart';

/// 주간 페이지 열람 수 관리
class WeeklyPagesStore {
  WeeklyPagesStore._();

  static final WeeklyPagesStore instance = WeeklyPagesStore._();

  static const _weekStartDateKey = 'pages_week_start_date_v1';
  static const _currentPagesKey = 'current_pages_v1';

  /// 현재 주간 페이지 수
  final ValueNotifier<int> currentPages = ValueNotifier(0);

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
    final pages = prefs.getInt(_currentPagesKey) ?? 0;

    if (weekStartDateStr != null) {
      _weekStartDate = DateTime.parse(weekStartDateStr);
    }

    currentPages.value = pages;

    appLogger.d(
      '[WeeklyPagesStore] Loaded: weekStart=$weekStartDateStr, pages=$pages',
    );
  }

  /// 앱 시작 시 호출: 주간 리셋 체크
  Future<void> checkWeeklyReset() async {
    await load();

    final today = DateTime.now();
    final thisWeekStart = _getMondayOfWeek(today);

    if (_weekStartDate == null) {
      // 첫 실행
      _weekStartDate = thisWeekStart;
      currentPages.value = 0;
      await _save();
      appLogger.i('[WeeklyPagesStore] First launch → reset to 0');
      return;
    }

    if (_weekStartDate!.isBefore(thisWeekStart)) {
      // 새로운 주 시작 → 리셋
      _weekStartDate = thisWeekStart;
      currentPages.value = 0;
      await _save();
      appLogger.i('[WeeklyPagesStore] New week started → reset to 0');
    }
  }

  /// 페이지 수 추가
  Future<void> addPages(int count) async {
    await load();
    currentPages.value += count;
    await _save();
    appLogger.d(
      '[WeeklyPagesStore] Added pages: $count → total=${currentPages.value}',
    );
  }

  /// 다음 리셋까지 남은 일수
  int get daysUntilReset {
    if (_weekStartDate == null) return 0;
    final nextWeekStart = _weekStartDate!.add(const Duration(days: 7));
    final today = DateTime.now();
    return nextWeekStart.difference(today).inDays;
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
    await prefs.setInt(_currentPagesKey, currentPages.value);
  }

  /// 해당 주의 월요일 구하기
  DateTime _getMondayOfWeek(DateTime date) {
    final weekday = date.weekday; // 1=Monday, 7=Sunday
    final daysToMonday = weekday - 1;
    final monday = date.subtract(Duration(days: daysToMonday));
    return DateTime(monday.year, monday.month, monday.day); // 시간 제거
  }
}
