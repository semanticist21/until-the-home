import 'package:flutter/material.dart';

/// 서버 변환 중 로딩 화면
///
/// NAS API를 통한 문서 변환(HWP, HWPX, DOC, XLS, PPT, PPTX) 시 표시
class AppServerConversionLoading extends StatelessWidget {
  const AppServerConversionLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(
            '서버에서 문서를 변환 중이에요.\n파일 크기에 따라 시간이 걸릴 수 있어요.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
