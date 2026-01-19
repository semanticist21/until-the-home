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
import '../../core/utils/file-resolver.dart';
import '../../core/utils/navigation_utils.dart';
import '../docx_viewer/index.dart';
import '../universal_pdf_viewer/index.dart';

bool _isAssetPath(String path) {
  if (path.startsWith('content://') || path.startsWith('file://')) {
    return false;
  }
  if (path.startsWith('assets/') || path.startsWith('test_samples/')) {
    return true;
  }
  if (path.startsWith('/')) {
    return false; // Unix/Linux/macOS absolute paths
  }
  if (RegExp(r'^[A-Za-z]:\\').hasMatch(path)) {
    return false; // Windows absolute paths
  }
  return true;
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

  late final String resolvedPath;
  late final String resolvedName;
  late final String resolvedType;
  int? resolvedSizeBytes;

  if (isAsset) {
    resolvedPath = doc.path;
    resolvedName = doc.name;
    resolvedType = doc.type;
  } else {
    try {
      final resolved = await FileResolver.resolve(
        doc.path,
        suggestedName: doc.name,
      );
      resolvedPath = resolved.path;
      resolvedName = resolved.displayName;
      resolvedType = _resolveDocumentType(doc.type, resolvedName, resolvedPath);
      resolvedSizeBytes = resolved.sizeBytes;
    } catch (e, st) {
      appLogger.e(
        '[HANDLER] Failed to resolve shared file',
        error: e,
        stackTrace: st,
      );
      if (!context.mounted) return false;
      await _showOpenError(
        context,
        '공유된 파일에 접근할 수 없습니다.\n다시 공유하거나 파일을 다시 선택해주세요.',
      );
      return false;
    }
  }

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
    'isAsset: $isAsset, type: $resolvedType, '
    'isSupported: ${nativeViewerFormats.contains(resolvedType)}',
  );

  if (preferNative && !isAsset && nativeViewerFormats.contains(resolvedType)) {
    appLogger.i(
      '[HANDLER] Attempting to open with native viewer: $resolvedType',
    );
    appLogger.d('[HANDLER] File path: $resolvedPath');

    try {
      final result = await OpenFilex.open(resolvedPath);
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
      'isSupported: ${nativeViewerFormats.contains(resolvedType)}',
    );
  }

  // Async gap 후 context 사용 전 mounted 체크
  if (!context.mounted) return false;

  if (_isNasConversionType(resolvedType) && !isAsset) {
    final sizeBytes = resolvedSizeBytes ?? await _readFileSize(resolvedPath);
    if (!context.mounted) return false;
    if (sizeBytes != null && sizeBytes > _maxNasFileSize) {
      final sizeMB = (sizeBytes / (1024 * 1024)).toStringAsFixed(1);
      if (!context.mounted) return false;
      await _showOpenError(
        context,
        '변환 가능한 파일 크기는 25MB까지입니다.\n선택한 파일: $sizeMB MB',
      );
      return false;
    }
  }

  switch (resolvedType) {
    case 'PDF':
      NavigationUtils.pushScreen(
        context,
        (_) => UniversalPdfViewer(
          filePath: resolvedPath,
          title: resolvedName,
          isAsset: isAsset,
        ),
      );
      return true;

    case 'TXT':
      NavigationUtils.pushScreen(
        context,
        (_) => UniversalPdfViewer(
          filePath: resolvedPath,
          title: resolvedName,
          isAsset: isAsset,
          converter: TxtToPdfConverter(),
        ),
      );
      return true;

    case 'CSV':
      NavigationUtils.pushScreen(
        context,
        (_) => UniversalPdfViewer(
          filePath: resolvedPath,
          title: resolvedName,
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
          filePath: resolvedPath,
          title: resolvedName,
          isAsset: isAsset,
          converter: NasToPdfConverter(),
        ),
      );
      return true;

    case 'DOCX':
      NavigationUtils.pushScreen(
        context,
        (_) => DocxViewerScreen(
          filePath: resolvedPath,
          title: resolvedName,
          isAsset: isAsset,
        ),
      );
      return true;
    case 'XLSX':
      NavigationUtils.pushScreen(
        context,
        (_) => UniversalPdfViewer(
          filePath: resolvedPath,
          title: resolvedName,
          isAsset: isAsset,
          converter: NasToPdfConverter(),
        ),
      );
      return true;

    default:
      appLogger.w('[HANDLER] Unsupported type: ${doc.type}');
      return false;
  }
}

const int _maxNasFileSize = 25 * 1024 * 1024;

bool _isNasConversionType(String type) {
  return {'HWP', 'HWPX', 'DOC', 'XLS', 'XLSX', 'PPT', 'PPTX'}.contains(type);
}

String _resolveDocumentType(String type, String name, String path) {
  if (type != 'FILE') {
    return type;
  }
  final fromName = _extensionFromPath(name);
  if (fromName.isNotEmpty) {
    return fromName;
  }
  final fromPath = _extensionFromPath(path);
  return fromPath.isNotEmpty ? fromPath : type;
}

String _extensionFromPath(String path) {
  final ext = path.split('.').last;
  if (ext.isEmpty || ext == path) {
    return '';
  }
  return ext.toUpperCase();
}

Future<int?> _readFileSize(String path) async {
  try {
    final file = File(path);
    if (!await file.exists()) {
      return null;
    }
    return await file.length();
  } catch (e, st) {
    appLogger.w('[HANDLER] Failed to read file size', error: e, stackTrace: st);
    return null;
  }
}

Future<void> _showOpenError(BuildContext context, String message) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('파일을 열 수 없습니다'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('확인'),
        ),
      ],
    ),
  );
}
