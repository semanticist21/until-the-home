import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/converters/csv_to_pdf_converter.dart';
import '../../core/converters/nas_to_pdf_converter.dart';
import '../../core/converters/txt_to_pdf_converter.dart';
import '../../core/data/recent_documents_store.dart';
import '../../core/utils/app_logger.dart';
import '../docx_viewer/index.dart';
import '../universal_pdf_viewer/index.dart';

bool _isAssetPath(String path) {
  if (path.startsWith('test_samples/')) {
    return true;
  }
  try {
    return !File(path).existsSync();
  } catch (_) {
    return true;
  }
}

/// 확장자별 문서 뷰어를 여는 통합 핸들러
bool openRecentDocument(BuildContext context, RecentDocument doc) {
  final isAsset = _isAssetPath(doc.path);
  appLogger.d(
    '[HANDLER] Opening ${doc.type} - path: ${doc.path}, isAsset: $isAsset',
  );

  switch (doc.type) {
    case 'PDF':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => UniversalPdfViewer(
            filePath: doc.path,
            title: doc.name,
            isAsset: isAsset,
          ),
        ),
      );
      return true;

    case 'TXT':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => UniversalPdfViewer(
            filePath: doc.path,
            title: doc.name,
            isAsset: isAsset,
            converter: TxtToPdfConverter(),
          ),
        ),
      );
      return true;

    case 'CSV':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => UniversalPdfViewer(
            filePath: doc.path,
            title: doc.name,
            isAsset: isAsset,
            converter: CsvToPdfConverter(),
          ),
        ),
      );
      return true;

    case 'HWP':
    case 'HWPX':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => UniversalPdfViewer(
            filePath: doc.path,
            title: doc.name,
            isAsset: isAsset,
            converter: NasToPdfConverter(),
          ),
        ),
      );
      return true;

    case 'PPTX':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => UniversalPdfViewer(
            filePath: doc.path,
            title: doc.name,
            isAsset: isAsset,
            converter: NasToPdfConverter(),
          ),
        ),
      );
      return true;

    case 'DOCX':
    case 'DOC':
    case 'XLS':
    case 'XLSX':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DocxViewerScreen(
            filePath: doc.path,
            title: doc.name,
            isAsset: isAsset,
          ),
        ),
      );
      return true;

    default:
      appLogger.w('[HANDLER] Unsupported type: ${doc.type}');
      return false;
  }
}
