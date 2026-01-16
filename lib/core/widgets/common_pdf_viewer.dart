import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';

import '../utils/app_logger.dart';
import 'app_loading.dart';
import 'search_bottom_bar.dart';

/// 공통 PDF 뷰어 위젯
/// PDF, TXT(→PDF), CSV(→PDF) 모두 동일한 뷰어 사용
class CommonPdfViewer extends StatefulWidget {
  const CommonPdfViewer({
    super.key,
    this.assetPath,
    this.filePath,
    this.pdfBytes,
    required this.title,
    this.onSave,
  }) : assert(
         assetPath != null || filePath != null || pdfBytes != null,
         'assetPath, filePath, or pdfBytes must be provided',
       );

  /// Asset 경로 (예: 'assets/sample.pdf')
  final String? assetPath;

  /// 파일 경로 (실제 파일 시스템 경로)
  final String? filePath;

  /// PDF 바이트 데이터 (TXT/CSV 변환 후 사용)
  final Uint8List? pdfBytes;

  /// 화면 제목
  final String title;

  /// PDF 저장 버튼 콜백 (선택적)
  final VoidCallback? onSave;

  @override
  State<CommonPdfViewer> createState() => _CommonPdfViewerState();
}

class _CommonPdfViewerState extends State<CommonPdfViewer> {
  PdfViewerController? _controller;
  PdfTextSearcher? _textSearcher;
  PdfDocument? _document;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoading = true;
  String? _error;

  // Search
  bool _showSearchInput = false;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  String _searchQuery = '';
  int _matchCount = 0;
  int? _currentMatchIndex;

  @override
  void initState() {
    super.initState();
    appLogger.d('[COMMON_PDF_VIEWER] initState - title: ${widget.title}');
    _initPdf();
  }

  Future<void> _initPdf() async {
    appLogger.i('[COMMON_PDF_VIEWER] _initPdf START');
    try {
      PdfDocument document;

      if (widget.pdfBytes != null) {
        // PDF 바이트 데이터로 열기 (TXT/CSV 변환 후)
        appLogger.d('[COMMON_PDF_VIEWER] Loading from bytes');
        document = await PdfDocument.openData(widget.pdfBytes!);
      } else if (widget.assetPath != null) {
        // Asset 파일을 임시 파일로 복사 후 로드
        appLogger.d(
          '[COMMON_PDF_VIEWER] Loading as ASSET: ${widget.assetPath}',
        );
        final byteData = await rootBundle.load(widget.assetPath!);
        appLogger.d(
          '[COMMON_PDF_VIEWER] Asset loaded, size: ${byteData.lengthInBytes} bytes',
        );
        final tempDir = await getTemporaryDirectory();
        final fileName = widget.assetPath!.split('/').last;
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(byteData.buffer.asUint8List());
        appLogger.d('[COMMON_PDF_VIEWER] Temp file created: ${tempFile.path}');
        document = await PdfDocument.openFile(tempFile.path);
      } else if (widget.filePath != null) {
        // 파일 경로로 열기
        appLogger.d('[COMMON_PDF_VIEWER] Loading as FILE: ${widget.filePath}');
        final file = File(widget.filePath!);
        final exists = await file.exists();
        appLogger.d('[COMMON_PDF_VIEWER] File exists: $exists');
        if (!exists) {
          throw Exception('File not found: ${widget.filePath}');
        }
        document = await PdfDocument.openFile(widget.filePath!);
      } else {
        throw Exception('No PDF source provided');
      }

      appLogger.i(
        '[COMMON_PDF_VIEWER] Document opened, pages: ${document.pages.length}',
      );
      final controller = PdfViewerController();
      appLogger.d('[COMMON_PDF_VIEWER] Controller created');

      if (!mounted) {
        appLogger.w(
          '[COMMON_PDF_VIEWER] Widget not mounted, aborting setState',
        );
        return;
      }

      // Add slight delay to ensure smooth transition
      await Future.delayed(const Duration(milliseconds: 50));

      if (!mounted) {
        return;
      }

      setState(() {
        _document = document;
        _controller = controller;
        _totalPages = document.pages.length;
        _isLoading = false;
      });

      appLogger.i(
        '[COMMON_PDF_VIEWER] _initPdf SUCCESS - TextSearcher will be lazily initialized',
      );
    } catch (e, stackTrace) {
      appLogger.e(
        '[COMMON_PDF_VIEWER] _initPdf ERROR',
        error: e,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _textSearcher?.removeListener(_updateSearchResults);
    _textSearcher?.dispose();
    _document?.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _updateSearchResults() {
    if (mounted) {
      setState(() {
        _matchCount = _textSearcher?.matches.length ?? 0;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _currentMatchIndex = null;
      _matchCount = 0;
    });

    if (_searchQuery.isEmpty) {
      _textSearcher?.resetTextSearch();
      return;
    }

    // Lazy initialization: TextSearcher를 처음 검색할 때 생성
    if (_textSearcher == null && _controller != null) {
      try {
        appLogger.d(
          '[COMMON_PDF_VIEWER] Creating TextSearcher (lazy initialization)',
        );
        _textSearcher = PdfTextSearcher(_controller!)
          ..addListener(_updateSearchResults);
        appLogger.i('[COMMON_PDF_VIEWER] TextSearcher created successfully');
      } catch (e, stackTrace) {
        appLogger.e(
          '[COMMON_PDF_VIEWER] Failed to create TextSearcher',
          error: e,
          stackTrace: stackTrace,
        );
        return;
      }
    }

    if (_textSearcher == null) {
      appLogger.w(
        '[COMMON_PDF_VIEWER] TextSearcher is still null, cannot search',
      );
      return;
    }

    // Use PdfTextSearcher for searching
    _textSearcher!.startTextSearch(_searchQuery, caseInsensitive: true);

    // Match count will be updated by listener
    // Navigate to first match when available
    if (_textSearcher!.matches.isNotEmpty) {
      setState(() {
        _currentMatchIndex = 0;
      });
      _textSearcher!.goToMatchOfIndex(0);
    }
  }

  void _onPreviousMatch() {
    if (_textSearcher == null || _matchCount == 0) return;
    setState(() {
      final index = (_currentMatchIndex ?? 0) - 1;
      _currentMatchIndex = index < 0 ? _matchCount - 1 : index;
      _textSearcher!.goToMatchOfIndex(_currentMatchIndex ?? 0);
    });
  }

  void _onNextMatch() {
    if (_textSearcher == null || _matchCount == 0) return;
    setState(() {
      _currentMatchIndex = ((_currentMatchIndex ?? -1) + 1) % _matchCount;
      _textSearcher!.goToMatchOfIndex(_currentMatchIndex ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
        actions: [
          if (widget.onSave != null)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: widget.onSave,
              tooltip: 'PDF로 저장',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AppLoading();
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                '파일을 열 수 없습니다',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(child: _buildPdfViewer()),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildPdfViewer() {
    if (widget.pdfBytes != null) {
      // PDF 바이트 데이터로 렌더링
      return PdfViewer.data(
        widget.pdfBytes!,
        sourceName: widget.title,
        controller: _controller,
        params: _buildPdfViewerParams(),
      );
    } else if (widget.assetPath != null) {
      // Asset으로 렌더링
      return PdfViewer.asset(
        widget.assetPath!,
        controller: _controller,
        params: _buildPdfViewerParams(),
      );
    } else {
      // 파일로 렌더링
      return PdfViewer.file(
        widget.filePath!,
        controller: _controller,
        params: _buildPdfViewerParams(),
      );
    }
  }

  PdfViewerParams _buildPdfViewerParams() {
    return PdfViewerParams(
      // 투명한 하이라이트 색상으로 텍스트가 보이도록 설정
      matchTextColor: Colors.yellow.withValues(alpha: 0.3),
      activeMatchTextColor: Colors.orange.withValues(alpha: 0.5),
      pagePaintCallbacks: [
        if (_textSearcher != null) _textSearcher!.pageTextMatchPaintCallback,
      ],
      onPageChanged: (page) {
        setState(() {
          _currentPage = page ?? 1;
        });
      },
      loadingBannerBuilder: (context, bytesDownloaded, totalBytes) =>
          const Center(child: CircularProgressIndicator()),
      errorBannerBuilder: (context, error, stackTrace, documentRef) =>
          Center(child: Text(error.toString())),
    );
  }

  Widget _buildBottomBar() {
    return SearchBottomBar(
      showSearchInput: _showSearchInput,
      searchController: _searchController,
      searchFocusNode: _searchFocusNode,
      onSearchChanged: _onSearchChanged,
      onSearchToggle: () {
        setState(() {
          _showSearchInput = true;
        });
        _searchFocusNode.requestFocus();
      },
      onSearchClose: () {
        _textSearcher?.resetTextSearch();
        setState(() {
          _showSearchInput = false;
          _searchController.clear();
          _searchQuery = '';
          _matchCount = 0;
          _currentMatchIndex = null;
        });
      },
      matchCount: _matchCount,
      currentMatchIndex: _currentMatchIndex,
      onPreviousMatch: _onPreviousMatch,
      onNextMatch: _onNextMatch,
      infoWidget: _showSearchInput
          ? null
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentPage > 1
                      ? () =>
                            _controller?.goToPage(pageNumber: _currentPage - 1)
                      : null,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_currentPage / $_totalPages',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _currentPage < _totalPages
                      ? () =>
                            _controller?.goToPage(pageNumber: _currentPage + 1)
                      : null,
                  color: Colors.grey.shade700,
                ),
              ],
            ),
    );
  }
}
