import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'document_converter.dart';

/// TXT 파일을 PDF로 변환하는 컨버터
class TxtToPdfConverter implements DocumentConverter {
  @override
  String get converterType => 'txt';

  @override
  Future<Uint8List> convertToPdf(
    String filePath, {
    bool isAsset = false,
  }) async {
    // 1. TXT 파일 읽기
    String textContent;
    if (isAsset) {
      textContent = await rootBundle.loadString(filePath);
    } else {
      textContent = await File(filePath).readAsString();
    }

    // 2. PDF로 변환
    return _convertTextToPdf(textContent);
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
}
