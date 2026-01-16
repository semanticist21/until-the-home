import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Application-wide logger instance
///
/// Debug 모드에서만 출력되며, Release 빌드에서는 로그가 출력되지 않습니다.
///
/// 사용법:
/// ```dart
/// appLogger.d('Debug message');
/// appLogger.i('Info message');
/// appLogger.w('Warning message');
/// appLogger.e('Error message', error: exception, stackTrace: stack);
/// ```
final appLogger = Logger(
  filter: _KkomiLogFilter(),
  printer: PrettyPrinter(
    methodCount: 0, // 스택 트레이스 제거
    errorMethodCount: 5, // 에러 시에만 스택 트레이스 표시
    lineLength: 80, // 한 줄 길이
    colors: true, // 컬러 출력
    printEmojis: true, // 이모지 사용
    dateTimeFormat: DateTimeFormat.none, // 시간 표시 제거 (Flutter 로그에 이미 포함)
  ),
);

/// Debug 모드에서만 로그를 출력하는 필터
class _KkomiLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return kDebugMode; // Release 빌드에서는 로그 출력 안 함
  }
}
