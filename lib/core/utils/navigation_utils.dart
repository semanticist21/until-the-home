import 'package:flutter/material.dart';

/// 네비게이션 관련 유틸리티 함수
class NavigationUtils {
  NavigationUtils._();

  /// 화면을 푸시하는 헬퍼 메서드
  ///
  /// MaterialPageRoute를 생성하고 푸시하는 보일러플레이트를 줄입니다.
  ///
  /// [context]: BuildContext
  /// [builder]: 화면 위젯을 생성하는 builder 함수
  static void pushScreen(
    BuildContext context,
    Widget Function(BuildContext) builder,
  ) {
    Navigator.of(context).push(MaterialPageRoute(builder: builder));
  }

  /// 화면을 푸시하고 Future를 반환하는 헬퍼 메서드
  ///
  /// [context]: BuildContext
  /// [builder]: 화면 위젯을 생성하는 builder 함수
  /// Returns: Navigator.push의 결과 Future
  static Future<T?> pushScreenWithResult<T>(
    BuildContext context,
    Widget Function(BuildContext) builder,
  ) {
    return Navigator.of(context).push<T>(MaterialPageRoute(builder: builder));
  }
}
