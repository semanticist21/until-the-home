import 'package:flutter/material.dart';

import '../../core/widgets/common_pdf_viewer.dart';

/// PDF 뷰어 화면
/// CommonPdfViewer를 사용하여 PDF 파일 표시
class PdfViewerScreen extends StatelessWidget {
  const PdfViewerScreen({
    super.key,
    required this.assetPath,
    required this.title,
    this.isAsset = true,
  });

  final String assetPath;
  final String title;
  final bool isAsset;

  @override
  Widget build(BuildContext context) {
    return CommonPdfViewer(
      assetPath: isAsset ? assetPath : null,
      filePath: !isAsset ? assetPath : null,
      title: title,
    );
  }
}
