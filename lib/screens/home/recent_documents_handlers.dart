import 'package:flutter/material.dart';

import '../../core/converters/csv_to_pdf_converter.dart';
import '../../core/converters/nas_to_pdf_converter.dart';
import '../../core/converters/txt_to_pdf_converter.dart';
import '../../core/data/recent_documents_store.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/navigation_utils.dart';
import '../docx_viewer/index.dart';
import '../universal_pdf_viewer/index.dart';

bool _isAssetPath(String path) {
  // Asset paths don't start with absolute path indicators
  // Check for common asset path prefixes
  return path.startsWith('assets/') ||
      path.startsWith('test_samples/') ||
      !path.startsWith('/'); // Unix/Linux/macOS absolute paths
}

/// 확장자별 문서 뷰어를 여는 통합 핸들러
bool openRecentDocument(BuildContext context, RecentDocument doc) {
  final isAsset = _isAssetPath(doc.path);
  appLogger.d(
    '[HANDLER] Opening ${doc.type} - path: ${doc.path}, isAsset: $isAsset',
  );

  switch (doc.type) {
    case 'PDF':
      NavigationUtils.pushScreen(
        context,
        (_) => UniversalPdfViewer(
          filePath: doc.path,
          title: doc.name,
          isAsset: isAsset,
        ),
      );
      return true;

    case 'TXT':
      NavigationUtils.pushScreen(
        context,
        (_) => UniversalPdfViewer(
          filePath: doc.path,
          title: doc.name,
          isAsset: isAsset,
          converter: TxtToPdfConverter(),
        ),
      );
      return true;

    case 'CSV':
      NavigationUtils.pushScreen(
        context,
        (_) => UniversalPdfViewer(
          filePath: doc.path,
          title: doc.name,
          isAsset: isAsset,
          converter: CsvToPdfConverter(),
        ),
      );
      return true;

    case 'HWP':
    case 'HWPX':
      NavigationUtils.pushScreen(
        context,
        (_) => UniversalPdfViewer(
          filePath: doc.path,
          title: doc.name,
          isAsset: isAsset,
          converter: NasToPdfConverter(),
        ),
      );
      return true;

    case 'PPTX':
      NavigationUtils.pushScreen(
        context,
        (_) => UniversalPdfViewer(
          filePath: doc.path,
          title: doc.name,
          isAsset: isAsset,
          converter: NasToPdfConverter(),
        ),
      );
      return true;

    case 'DOCX':
    case 'DOC':
    case 'XLS':
    case 'XLSX':
      NavigationUtils.pushScreen(
        context,
        (_) => DocxViewerScreen(
          filePath: doc.path,
          title: doc.name,
          isAsset: isAsset,
        ),
      );
      return true;

    default:
      appLogger.w('[HANDLER] Unsupported type: ${doc.type}');
      return false;
  }
}
