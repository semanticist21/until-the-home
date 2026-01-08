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

    // 한글 지원 폰트 로드
    final fontData = await rootBundle.load(
      'assets/fonts/NotoSansCJKkr-Regular.otf',
    );
    final font = pw.Font.ttf(fontData);

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
                          font: font,
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
    super.dispose();
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
    );
  }
}
