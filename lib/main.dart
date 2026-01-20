import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path/path.dart' as p;
import 'package:pdfrx/pdfrx.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'core/data/recent_documents_store.dart';
import 'core/data/settings_store.dart';
import 'core/data/usage_streak_store.dart';
import 'core/data/weekly_limit_store.dart';
import 'core/data/weekly_pages_store.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'screens/home/index.dart';
import 'screens/home/recent_documents_handlers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  pdfrxFlutterInitialize(dismissPdfiumWasmWarnings: true);
  timeago.setLocaleMessages('ko', timeago.KoMessages());

  // 모든 Store 초기화를 병렬로 실행 (부팅 시간 단축)
  await Future.wait([
    SettingsStore.instance.init(),
    UsageStreakStore.instance.updateStreak(),
    WeeklyLimitStore.instance.checkWeeklyReset(),
    WeeklyPagesStore.instance.checkWeeklyReset(),
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _intentSub;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initSharingIntent();
  }

  void _initSharingIntent() {
    // 앱이 실행 중일 때 공유된 파일 처리
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> files) {
        if (files.isNotEmpty) {
          unawaited(_handleSharedFile(files.first));
        }
      },
      onError: (err) {
        appLogger.e('[SHARING] Error receiving shared file', error: err);
      },
    );

    // 앱이 닫혀있을 때 공유된 파일 처리
    ReceiveSharingIntent.instance.getInitialMedia().then((
      List<SharedMediaFile> files,
    ) {
      if (files.isNotEmpty) {
        unawaited(_handleSharedFile(files.first));
        ReceiveSharingIntent.instance.reset();
      }
    });
  }

  Future<void> _handleSharedFile(SharedMediaFile file) async {
    final filePath = file.path;
    final meta = _deriveSharedFileMeta(file);
    final fileName = meta.fileName;
    final extension = meta.extension;

    appLogger.i('[SHARING] Received file: $fileName, type: $extension');

    // 최근 문서에 추가
    await RecentDocumentsStore.instance.addDocument(
      filePath,
      name: fileName,
      type: extension,
      openedAt: DateTime.now(),
    );

    // RecentDocument 객체 생성 (뷰어 열기용)
    final doc = RecentDocument(
      path: filePath,
      type: extension,
      name: fileName,
      openedAt: DateTime.now(),
    );

    // 파일 열기 (약간의 딜레이로 UI가 준비될 때까지 대기)
    Future.delayed(const Duration(milliseconds: 500), () async {
      final context = _navigatorKey.currentContext;
      if (context != null && mounted) {
        // ignore: use_build_context_synchronously
        final success = await openRecentDocument(context, doc);
        if (!success) {
          appLogger.w('[SHARING] Unsupported file type: $extension');
        }
      }
    });
  }

  @override
  void dispose() {
    _intentSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.light;

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'kkomi',
      debugShowCheckedModeBanner: false,
      locale: const Locale('en', 'US'),
      localizationsDelegates: FLocalizations.localizationsDelegates,
      supportedLocales: FLocalizations.supportedLocales,
      // ignore: experimental_member_use
      theme: theme.toApproximateMaterialTheme(),
      builder: (context, child) => FTheme(data: theme, child: child!),
      home: const HomeScreen(),
    );
  }
}

({String fileName, String extension}) _deriveSharedFileMeta(
  SharedMediaFile file,
) {
  final path = file.path;
  String fileName = p.basename(path);
  final uri = Uri.tryParse(path);
  if ((fileName.isEmpty || fileName == path) &&
      uri != null &&
      uri.pathSegments.isNotEmpty) {
    fileName = uri.pathSegments.last;
  }

  String extension = _extensionFromPath(path);
  if (extension.isEmpty) {
    extension = _extensionFromPath(fileName);
  }
  if (extension.isEmpty) {
    extension = _extensionFromMime(file.mimeType);
  }
  if (extension.isEmpty) {
    extension = 'FILE';
  }

  if (fileName.isEmpty) {
    fileName = extension == 'FILE'
        ? 'shared_file'
        : 'shared_file.${extension.toLowerCase()}';
  }

  return (fileName: fileName, extension: extension);
}

String _extensionFromPath(String path) {
  final ext = p.extension(path);
  if (ext.isEmpty) {
    return '';
  }
  return ext.replaceFirst('.', '').toUpperCase();
}

String _extensionFromMime(String? mimeType) {
  if (mimeType == null || mimeType.isEmpty) {
    return '';
  }
  const mimeToExt = {
    'application/pdf': 'PDF',
    'text/plain': 'TXT',
    'text/csv': 'CSV',
    'application/csv': 'CSV',
    'application/vnd.hancom.hwp': 'HWP',
    'application/vnd.hancom.hwpx': 'HWPX',
    'application/msword': 'DOC',
    'application/vnd.ms-excel': 'XLS',
    'application/vnd.ms-powerpoint': 'PPT',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        'DOCX',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': 'XLSX',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation':
        'PPTX',
  };
  return mimeToExt[mimeType] ?? '';
}
