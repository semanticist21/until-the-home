import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart' as pdfx;

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
  pdfx.PdfControllerPinch? _controller;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoading = true;
  String? _error;

  // Page jump mode
  bool _isPageJumpMode = false;
  final _pageInputController = TextEditingController();
  final _pageInputFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadAndConvert();
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
      final document = await pdfx.PdfDocument.openData(pdfBytes);

      setState(() {
        _controller = pdfx.PdfControllerPinch(document: Future.value(document));
        _totalPages = document.pagesCount;
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
      rootBundle.load('assets/fonts/NotoSansKR-Regular.ttf'), // Korean
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
      ), // Russian/Ukrainian
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
      rootBundle.load('assets/fonts/NotoSans-Regular.ttf'), // Latin (fallback)
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
    _controller?.dispose();
    _pageInputController.dispose();
    _pageInputFocusNode.dispose();
    super.dispose();
  }

  void _togglePageJumpMode() {
    setState(() {
      _isPageJumpMode = !_isPageJumpMode;
      if (_isPageJumpMode) {
        _pageInputController.text = _currentPage.toString();
        // Focus and select all text after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _pageInputFocusNode.requestFocus();
          _pageInputController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _pageInputController.text.length,
          );
        });
      } else {
        _pageInputController.clear();
      }
    });
  }

  void _jumpToPage() {
    final pageNum = int.tryParse(_pageInputController.text);
    if (pageNum != null && pageNum >= 1 && pageNum <= _totalPages) {
      _controller?.jumpToPage(pageNum);
      _togglePageJumpMode();
    } else {
      // Invalid page - show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('1 ~ $_totalPages 사이의 페이지를 입력하세요'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('텍스트를 PDF로 변환 중...'),
          ],
        ),
      );
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
          child: pdfx.PdfViewPinch(
            controller: _controller!,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            builders: pdfx.PdfViewPinchBuilders<pdfx.DefaultBuilderOptions>(
              options: const pdfx.DefaultBuilderOptions(),
              documentLoaderBuilder: (_) =>
                  const Center(child: CircularProgressIndicator()),
              pageLoaderBuilder: (_) =>
                  const Center(child: CircularProgressIndicator()),
              errorBuilder: (_, error) => Center(child: Text(error.toString())),
            ),
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: _isPageJumpMode ? _buildPageJumpBar() : _buildNavigationBar(),
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Row(
      key: const ValueKey('navigation'),
      children: [
        // Left spacer for balance
        const SizedBox(width: 40),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 1
                    ? () => _controller?.previousPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      )
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
                    ? () => _controller?.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeIn,
                      )
                    : null,
                color: Colors.grey.shade700,
              ),
            ],
          ),
        ),
        // Page jump button on the right
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _togglePageJumpMode,
          color: Colors.grey.shade600,
          tooltip: '페이지 이동',
        ),
      ],
    );
  }

  Widget _buildPageJumpBar() {
    return Row(
      key: const ValueKey('pageJump'),
      children: [
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(
                  Icons.description_outlined,
                  size: 20,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _pageInputController,
                    focusNode: _pageInputFocusNode,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.go,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                    decoration: InputDecoration(
                      hintText: '1 ~ $_totalPages',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onSubmitted: (_) => _jumpToPage(),
                  ),
                ),
                Text(
                  '/ $_totalPages',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _jumpToPage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Close button
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: _togglePageJumpMode,
          color: Colors.grey.shade600,
          tooltip: '닫기',
        ),
      ],
    );
  }
}
