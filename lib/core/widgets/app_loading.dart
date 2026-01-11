import 'package:flutter/material.dart';

/// 공통 로딩 위젯 - CircularProgressIndicator만 표시
class AppLoading extends StatelessWidget {
  const AppLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// 오버레이 형태의 로딩 위젯
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({super.key, this.backgroundColor});

  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.grey.shade200,
      child: const AppLoading(),
    );
  }
}
