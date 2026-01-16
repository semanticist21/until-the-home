import 'package:flutter/material.dart';

import '../../core/data/recent_documents_store.dart';
import '../../core/utils/app_logger.dart';
import '../pdf_viewer/index.dart';

bool openRecentDocumentPdf(BuildContext context, RecentDocument doc) {
  appLogger.d(
    '[HANDLER_PDF] openRecentDocumentPdf - type: ${doc.type}, path: ${doc.path}, name: ${doc.name}',
  );

  if (doc.type != 'PDF') {
    appLogger.d('[HANDLER_PDF] Not PDF type, skipping');
    return false;
  }

  // test_samples/ 경로는 asset으로 처리
  final isAsset = doc.path.startsWith('test_samples/');
  appLogger.i('[HANDLER_PDF] Opening PDF with isAsset: $isAsset');
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) =>
          PdfViewerScreen(assetPath: doc.path, title: doc.name, isAsset: isAsset),
    ),
  );
  return true;
}
