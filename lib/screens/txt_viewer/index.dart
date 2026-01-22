import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/utils/pdf_export_utils.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/common_pdf_viewer.dart';

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
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  String? _error;

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

      setState(() {
        _pdfBytes = pdfBytes;
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
      rootBundle.load(
        'assets/fonts/NotoSans-Regular.ttf',
      ), // Latin Extended (Polish, Turkish 등)
      rootBundle.load('assets/fonts/NotoSansKR-Regular.ttf'), // Korean + Latin
      rootBundle.load(
        'assets/fonts/NotoSansCyrillic-Regular.ttf',
      ), // Russian/Ukrainian
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
    final primaryFont = fonts[1]; // Korean as primary
    final fallbackFonts = fonts.sublist(
      1,
    ); // Cyrillic 폰트를 앞쪽에 배치 (Latin Extended 일부 지원)

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
            content: const Text('PDF로 저장되었습니다'),
            action: SnackBarAction(
              label: '열기',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CommonPdfViewer(
                      filePath: pdfPath,
                      title: '${widget.title} (PDF)',
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
        body: const AppLoading(),
      );
    }

    if (_error != null) {
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
        body: Center(
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
        ),
      );
    }

    return CommonPdfViewer(
      pdfBytes: _pdfBytes,
      title: widget.title,
      onSave: _exportToPdf,
    );
  }
}
