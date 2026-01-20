import 'package:flutter/material.dart';

/// 공통 로딩 위젯 - CircularProgressIndicator 표시 (선택적 메시지)
class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.message});

  /// 선택적 로딩 메시지
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(
            message!,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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
