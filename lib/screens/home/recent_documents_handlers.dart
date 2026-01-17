import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../../core/converters/csv_to_pdf_converter.dart';
import '../../core/converters/nas_to_pdf_converter.dart';
import '../../core/converters/txt_to_pdf_converter.dart';
import '../../core/data/recent_documents_store.dart';
import '../../core/data/settings_store.dart';
import '../../core/data/weekly_limit_store.dart';
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
Future<bool> openRecentDocument(
  BuildContext context,
  RecentDocument doc,
) async {
  final isAsset = _isAssetPath(doc.path);
  appLogger.d(
    '[HANDLER] Opening ${doc.type} - path: ${doc.path}, isAsset: $isAsset',
  );

  // Native viewer 체크 (설정이 활성화되고, Asset이 아니고, 지원 포맷인 경우)
  // iOS: iWork(Pages/Numbers/Keynote) 내장 → DOCX/XLSX/PPTX 지원
  // Android: Office 앱 설치 여부 불확실 → 항상 앱 내부 뷰어 사용
  // 레거시 포맷(HWP/HWPX/DOC/XLS/PPT)은 모든 플랫폼에서 제외
  final nativeViewerFormats = Platform.isIOS
      ? ['DOCX', 'XLSX', 'PPTX']
      : <String>[];

  final preferNative = SettingsStore.instance.preferNativeViewer.value;
  appLogger.d(
    '[HANDLER] Native viewer check - preferNative: $preferNative, '
    'isAsset: $isAsset, type: ${doc.type}, '
    'isSupported: ${nativeViewerFormats.contains(doc.type)}',
  );

  if (preferNative && !isAsset && nativeViewerFormats.contains(doc.type)) {
    appLogger.i('[HANDLER] Attempting to open with native viewer: ${doc.type}');
    appLogger.d('[HANDLER] File path: ${doc.path}');

    try {
      final result = await OpenFilex.open(doc.path);
      appLogger.d(
        '[HANDLER] OpenFilex result - type: ${result.type}, '
        'message: ${result.message}',
      );

      if (result.type == ResultType.done) {
        // 주간 열람 카운트 +1 (페이지 카운트 없음)
        await WeeklyLimitStore.instance.addUsage(1);
        appLogger.i('[HANDLER] Native viewer opened successfully');
        return true;
      } else {
        appLogger.w(
          '[HANDLER] Native viewer failed - type: ${result.type}, '
          'message: ${result.message}',
        );
        // Native viewer 실패 시 fallback to app viewer
      }
    } catch (e, st) {
      appLogger.e('[HANDLER] Native viewer error', error: e, stackTrace: st);
      // Error 발생 시 fallback to app viewer
    }
  } else {
    appLogger.d(
      '[HANDLER] Skipping native viewer - '
      'preferNative: $preferNative, !isAsset: ${!isAsset}, '
      'isSupported: ${nativeViewerFormats.contains(doc.type)}',
    );
  }

  // Async gap 후 context 사용 전 mounted 체크
  if (!context.mounted) return false;

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
    case 'DOC':
    case 'XLS':
    case 'PPT':
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
