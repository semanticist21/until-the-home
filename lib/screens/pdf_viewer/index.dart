import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../core/utils/app_logger.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/search_bottom_bar.dart';

class PdfViewerScreen extends StatefulWidget {
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
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
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
    appLogger.d(
      '[PDF_VIEWER] initState - path: ${widget.assetPath}, isAsset: ${widget.isAsset}',
    );
    _initPdf();
  }

  Future<void> _initPdf() async {
    appLogger.i('[PDF_VIEWER] _initPdf START');
    try {
      PdfDocument document;
      if (widget.isAsset) {
        appLogger.d('[PDF_VIEWER] Loading as ASSET: ${widget.assetPath}');
        // Asset 파일을 임시 파일로 복사 후 로드
        final byteData = await rootBundle.load(widget.assetPath);
        appLogger.d(
          '[PDF_VIEWER] Asset loaded, size: ${byteData.lengthInBytes} bytes',
        );
        final tempDir = await getTemporaryDirectory();
        final fileName = widget.assetPath.split('/').last;
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(byteData.buffer.asUint8List());
        appLogger.d('[PDF_VIEWER] Temp file created: ${tempFile.path}');
        document = await PdfDocument.openFile(tempFile.path);
      } else {
        appLogger.d('[PDF_VIEWER] Loading as FILE: ${widget.assetPath}');
        final file = File(widget.assetPath);
        final exists = await file.exists();
        appLogger.d('[PDF_VIEWER] File exists: $exists');
        if (!exists) {
          throw Exception('File not found: ${widget.assetPath}');
        }
        document = await PdfDocument.openFile(widget.assetPath);
      }

      appLogger.i(
        '[PDF_VIEWER] Document opened, pages: ${document.pages.length}',
      );
      final controller = PdfViewerController();
      appLogger.d('[PDF_VIEWER] Controller created');

      if (!mounted) {
        appLogger.w('[PDF_VIEWER] Widget not mounted, aborting setState');
        return;
      }

      setState(() {
        _document = document;
        _controller = controller;
        _totalPages = document.pages.length;
        _isLoading = false;
      });

      appLogger.i(
        '[PDF_VIEWER] _initPdf SUCCESS - TextSearcher will be created when search is used',
      );
    } catch (e, stackTrace) {
      appLogger.e(
        '[PDF_VIEWER] _initPdf ERROR',
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
        appLogger.d('[PDF_VIEWER] Creating TextSearcher (lazy initialization)');
        _textSearcher = PdfTextSearcher(_controller!)
          ..addListener(_updateSearchResults);
        appLogger.i('[PDF_VIEWER] TextSearcher created successfully');
      } catch (e, stackTrace) {
        appLogger.e(
          '[PDF_VIEWER] Failed to create TextSearcher',
          error: e,
          stackTrace: stackTrace,
        );
        return;
      }
    }

    if (_textSearcher == null) {
      appLogger.w('[PDF_VIEWER] TextSearcher is still null, cannot search');
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
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    appLogger.d(
      '[PDF_VIEWER] _buildBody - isLoading: $_isLoading, error: $_error, controller: ${_controller != null ? "NOT NULL" : "NULL"}',
    );

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
                'PDF를 열 수 없습니다',
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
        Expanded(
          child: widget.isAsset
              ? PdfViewer.asset(
                  widget.assetPath,
                  controller: _controller,
                  params: PdfViewerParams(
                    // 투명한 하이라이트 색상으로 텍스트가 보이도록 설정
                    matchTextColor: Colors.yellow.withOpacity(0.3),
                    activeMatchTextColor: Colors.orange.withOpacity(0.5),
                    pagePaintCallbacks: [
                      if (_textSearcher != null)
                        _textSearcher!.pageTextMatchPaintCallback,
                    ],
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page ?? 1;
                      });
                    },
                    loadingBannerBuilder:
                        (context, bytesDownloaded, totalBytes) =>
                            const Center(child: CircularProgressIndicator()),
                    errorBannerBuilder:
                        (context, error, stackTrace, documentRef) =>
                            Center(child: Text(error.toString())),
                  ),
                )
              : PdfViewer.file(
                  widget.assetPath,
                  controller: _controller,
                  params: PdfViewerParams(
                    // 투명한 하이라이트 색상으로 텍스트가 보이도록 설정
                    matchTextColor: Colors.yellow.withOpacity(0.3),
                    activeMatchTextColor: Colors.orange.withOpacity(0.5),
                    pagePaintCallbacks: [
                      if (_textSearcher != null)
                        _textSearcher!.pageTextMatchPaintCallback,
                    ],
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page ?? 1;
                      });
                    },
                    loadingBannerBuilder:
                        (context, bytesDownloaded, totalBytes) =>
                            const Center(child: CircularProgressIndicator()),
                    errorBannerBuilder:
                        (context, error, stackTrace, documentRef) =>
                            Center(child: Text(error.toString())),
                  ),
                ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildBottomBar() {
    return SearchBottomBar(
      showSearchInput: _showSearchInput,
      searchController: _searchController,
      searchFocusNode: _searchFocusNode,
      matchCount: _matchCount,
      currentMatchIndex: _currentMatchIndex,
      onSearchToggle: () {
        setState(() {
          _showSearchInput = !_showSearchInput;
          if (!_showSearchInput) {
            _searchController.clear();
            _searchQuery = '';
            _textSearcher?.resetTextSearch();
            _matchCount = 0;
            _currentMatchIndex = null;
          }
        });
        if (_showSearchInput) {
          _searchFocusNode.requestFocus();
        }
      },
      onSearchClose: () {
        setState(() {
          _showSearchInput = false;
          _searchController.clear();
          _searchQuery = '';
          _textSearcher?.resetTextSearch();
          _matchCount = 0;
          _currentMatchIndex = null;
        });
      },
      onSearchChanged: _onSearchChanged,
      onPreviousMatch: _onPreviousMatch,
      onNextMatch: _onNextMatch,
      infoWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 1
                ? () => _controller?.goToPage(pageNumber: _currentPage - 1)
                : null,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                ? () => _controller?.goToPage(pageNumber: _currentPage + 1)
                : null,
            color: Colors.grey.shade700,
          ),
        ],
      ),
    );
  }
}

class PdfTextRangeWithPage {
  final int pageNumber;
  final int startIndex;
  final int endIndex;

  PdfTextRangeWithPage({
    required this.pageNumber,
    required this.startIndex,
    required this.endIndex,
  });
}
