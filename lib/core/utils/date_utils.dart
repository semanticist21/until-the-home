/// 날짜 관련 유틸리티 함수
class DateUtils {
  DateUtils._();

  /// 해당 주의 월요일 구하기
  ///
  /// [date]: 기준 날짜
  /// Returns: 해당 주의 월요일 (시간 정보 제거)
  static DateTime getMondayOfWeek(DateTime date) {
    final weekday = date.weekday; // 1=Monday, 7=Sunday
    final daysToMonday = weekday - 1;
    final monday = date.subtract(Duration(days: daysToMonday));
    return DateTime(monday.year, monday.month, monday.day); // 시간 제거
  }

  /// 오늘 날짜 문자열 반환 (YYYY-MM-DD)
  ///
  /// Returns: YYYY-MM-DD 형식의 날짜 문자열
  static String getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// 날짜 문자열을 안전하게 파싱
  ///
  /// [dateStr]: YYYY-MM-DD 또는 ISO8601 형식 날짜 문자열
  /// Returns: 파싱된 DateTime 객체
  /// Throws: FormatException if parsing fails
  static DateTime parseDate(String dateStr) {
    return DateTime.parse(dateStr);
  }

  /// 두 날짜 간의 일수 차이 계산
  ///
  /// [date1]: 첫 번째 날짜
  /// [date2]: 두 번째 날짜
  /// Returns: date2 - date1의 일수 차이
  static int daysBetween(DateTime date1, DateTime date2) {
    final normalizedDate1 = DateTime(date1.year, date1.month, date1.day);
    final normalizedDate2 = DateTime(date2.year, date2.month, date2.day);
    return normalizedDate2.difference(normalizedDate1).inDays;
  }
}
