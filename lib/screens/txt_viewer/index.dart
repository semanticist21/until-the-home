import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfrx/pdfrx.dart' as pdfrx;

import '../../core/utils/pdf_export_utils.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/search_bottom_bar.dart';
import '../pdf_viewer/index.dart';

class TxtViewerScreen extends StatefulWidget {
  const TxtViewerScreen({
    super.key,
    required this.filePath,
    required this.title,
    this.isAsset = false,
  });

  final String filePath;
  final String title;
  final bool isAsset;

  @override
  State<TxtViewerScreen> createState() => _TxtViewerScreenState();
}

class _TxtViewerScreenState extends State<TxtViewerScreen> {
  pdfrx.PdfViewerController? _controller;
  pdfrx.PdfTextSearcher? _textSearcher;
  pdfrx.PdfDocument? _document;
  Uint8List? _pdfBytes;
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
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _loadAndConvert();
    });
  }

  Future<void> _loadAndConvert() async {
    try {
      // 1. TXT 파일 읽기
      String textContent;
      if (widget.isAsset) {
        textContent = await rootBundle.loadString(widget.filePath);
      } else {
        textContent = await File(widget.filePath).readAsString();
      }

      // 2. PDF로 변환
      final pdfBytes = await _convertTextToPdf(textContent);

      // 3. PDF 문서 열기
      final document = await pdfrx.PdfDocument.openData(pdfBytes);

      final controller = pdfrx.PdfViewerController();
      final textSearcher = pdfrx.PdfTextSearcher(controller)
        ..addListener(_updateSearchResults);

      setState(() {
        _pdfBytes = pdfBytes;
        _document = document;
        _controller = controller;
        _textSearcher = textSearcher;
        _totalPages = document.pages.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<Uint8List> _convertTextToPdf(String text) async {
    final pdf = pw.Document();

    // 다국어 지원 폰트 로드
    final fontDataList = await Future.wait([
      rootBundle.load('assets/fonts/NotoSansKR-Regular.ttf'), // Korean + Latin
      rootBundle.load('assets/fonts/NotoSansJP-Regular.ttf'), // Japanese
      rootBundle.load(
        'assets/fonts/NotoSansSC-Regular.ttf',
      ), // Chinese Simplified
      rootBundle.load(
        'assets/fonts/NotoSansTC-Regular.ttf',
      ), // Chinese Traditional
      rootBundle.load('assets/fonts/NotoSansThai-Regular.ttf'), // Thai
      rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf'), // Arabic
      rootBundle.load('assets/fonts/NotoSansHebrew-Regular.ttf'), // Hebrew
      rootBundle.load('assets/fonts/NotoSansDevanagari-Regular.ttf'), // Hindi
      rootBundle.load(
        'assets/fonts/NotoSansCyrillic-Regular.ttf',
      ), // Russian/Ukrainian + Latin Extended
      rootBundle.load('assets/fonts/NotoSansGreek-Regular.ttf'), // Greek
      rootBundle.load('assets/fonts/NotoSansGeorgian-Regular.ttf'), // Georgian
      rootBundle.load('assets/fonts/NotoSansArmenian-Regular.ttf'), // Armenian
      rootBundle.load('assets/fonts/NotoSansBengali-Regular.ttf'), // Bengali
      rootBundle.load('assets/fonts/NotoSansTamil-Regular.ttf'), // Tamil
      rootBundle.load(
        'assets/fonts/NotoSansVietnamese-Regular.ttf',
      ), // Vietnamese
      rootBundle.load('assets/fonts/NotoSansMath-Regular.ttf'), // Math symbols
      rootBundle.load('assets/fonts/NotoSansSymbols-Regular.ttf'), // Symbols
      rootBundle.load(
        'assets/fonts/NotoSansSymbols2-Regular.ttf',
      ), // More symbols
    ]);

    final fonts = fontDataList.map((data) => pw.Font.ttf(data)).toList();
    final primaryFont = fonts[0]; // Korean as primary
    final fallbackFonts = fonts.sublist(1); // Rest as fallbacks

    // 텍스트를 라인별로 분리
    final lines = text.split('\n');

    // 페이지당 약 50줄
    const linesPerPage = 50;
    final pageCount = (lines.length / linesPerPage).ceil();

    for (var pageIndex = 0; pageIndex < pageCount; pageIndex++) {
      final startLine = pageIndex * linesPerPage;
      final endLine = (startLine + linesPerPage).clamp(0, lines.length);
      final pageLines = lines.sublist(startLine, endLine);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: pageLines
                  .map(
                    (line) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 4),
                      child: pw.Text(
                        line.isEmpty ? ' ' : line,
                        style: pw.TextStyle(
                          font: primaryFont,
                          fontFallback: fallbackFonts,
                          fontSize: 11,
                          lineSpacing: 1.5,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      );
    }

    return pdf.save();
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
    if (_textSearcher == null) return;

    setState(() {
      _searchQuery = query;
      _currentMatchIndex = null;
      _matchCount = 0;
    });

    if (_searchQuery.isEmpty) {
      _textSearcher!.resetTextSearch();
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
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportToPdf,
            tooltip: 'PDF로 저장',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Future<void> _exportToPdf() async {
    if (_pdfBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF 생성 중입니다. 잠시 후 다시 시도하세요.')),
      );
      return;
    }

    try {
      // 이미 생성된 PDF 바이트를 저장
      final pdfPath = await PdfExportUtils.savePdfToTemp(
        _pdfBytes!,
        widget.title,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF로 저장되었습니다'),
            action: SnackBarAction(
              label: '열기',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PdfViewerScreen(
                      assetPath: pdfPath,
                      title: '${widget.title} (PDF)',
                      isAsset: false,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('PDF 저장 실패: ${e.toString()}')));
      }
    }
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
        Expanded(
          child: pdfrx.PdfViewer.data(
            _pdfBytes!,
            sourceName: widget.title,
            controller: _controller,
            params: pdfrx.PdfViewerParams(
              matchTextColor: Colors.yellow.shade100,
              activeMatchTextColor: Colors.orange.shade200,
              pagePaintCallbacks: [
                if (_textSearcher != null)
                  _textSearcher!.pageTextMatchPaintCallback,
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
