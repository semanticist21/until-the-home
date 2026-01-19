import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TXT to PDF Conversion Tests', () {
    test('Convert simple ASCII text to PDF', () async {
      const textContent = 'Hello, World!\nThis is a test.';

      final pdfBytes = await _convertTextToPdf(textContent);

      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(100));

      // Verify PDF header
      final header = String.fromCharCodes(pdfBytes.take(5));
      expect(header, equals('%PDF-'));
    });

    test('Convert Korean text to PDF', () async {
      const textContent = '안녕하세요\n한글 테스트입니다.';

      final pdfBytes = await _convertTextToPdf(textContent);

      expect(pdfBytes, isNotEmpty);

      // Verify PDF header
      final header = String.fromCharCodes(pdfBytes.take(5));
      expect(header, equals('%PDF-'));
    });

    test('Convert multi-page text (>50 lines) to PDF', () async {
      final textContent = List.generate(100, (i) => 'Line ${i + 1}').join('\n');

      final pdfBytes = await _convertTextToPdf(textContent);

      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1000)); // Multi-page should be larger

      // Verify PDF header
      final header = String.fromCharCodes(pdfBytes.take(5));
      expect(header, equals('%PDF-'));
    });

    test('Convert empty text to PDF', () async {
      const textContent = '';

      final pdfBytes = await _convertTextToPdf(textContent);

      expect(pdfBytes, isNotEmpty);

      // Verify PDF header
      final header = String.fromCharCodes(pdfBytes.take(5));
      expect(header, equals('%PDF-'));
    });

    test('Convert text with special characters to PDF', () async {
      const textContent = 'Special: !@#\$%^&*()_+-=[]{}|;:,.<>?/~`';

      final pdfBytes = await _convertTextToPdf(textContent);

      expect(pdfBytes, isNotEmpty);

      // Verify PDF header
      final header = String.fromCharCodes(pdfBytes.take(5));
      expect(header, equals('%PDF-'));
    });

    test('Convert sample.txt from test_samples', () async {
      final textContent = await File('test_samples/sample.txt').readAsString();

      expect(textContent, isNotEmpty);

      final pdfBytes = await _convertTextToPdf(textContent);

      expect(pdfBytes, isNotEmpty);

      // Verify PDF header
      final header = String.fromCharCodes(pdfBytes.take(5));
      expect(header, equals('%PDF-'));
    });
  });
}

/// Helper function to convert text to PDF
/// This mirrors the logic in lib/screens/txt_viewer/index.dart
Future<Uint8List> _convertTextToPdf(String text) async {
  final pdf = pw.Document();

  // Load multi-language fonts from disk to avoid missing glyph warnings.
  final fontPaths = [
    'assets/fonts/NotoSansKR-Regular.ttf',
    'assets/fonts/NotoSansCyrillic-Regular.ttf',
    'assets/fonts/NotoSansJP-Regular.ttf',
    'assets/fonts/NotoSansSC-Regular.ttf',
    'assets/fonts/NotoSansTC-Regular.ttf',
    'assets/fonts/NotoSansThai-Regular.ttf',
    'assets/fonts/NotoSansArabic-Regular.ttf',
    'assets/fonts/NotoSansHebrew-Regular.ttf',
    'assets/fonts/NotoSansDevanagari-Regular.ttf',
    'assets/fonts/NotoSansGreek-Regular.ttf',
    'assets/fonts/NotoSansGeorgian-Regular.ttf',
    'assets/fonts/NotoSansArmenian-Regular.ttf',
    'assets/fonts/NotoSansBengali-Regular.ttf',
    'assets/fonts/NotoSansTamil-Regular.ttf',
    'assets/fonts/NotoSansVietnamese-Regular.ttf',
    'assets/fonts/NotoSansMath-Regular.ttf',
    'assets/fonts/NotoSansSymbols-Regular.ttf',
    'assets/fonts/NotoSansSymbols2-Regular.ttf',
  ];

  final fontDataList = <ByteData>[];
  for (final path in fontPaths) {
    final bytes = await File(path).readAsBytes();
    if (bytes.isNotEmpty) {
      fontDataList.add(ByteData.view(bytes.buffer));
    }
  }

  final fonts = fontDataList.map((data) => pw.Font.ttf(data)).toList();
  final font = fonts.isNotEmpty ? fonts.first : pw.Font.helvetica();
  final fallbackFonts = fonts.length > 1 ? fonts.sublist(1) : <pw.Font>[];

  // Split text into lines
  final sanitizedText = _sanitizeUnsupportedChars(text);
  final lines = sanitizedText.split('\n');

  // 50 lines per page
  const linesPerPage = 50;
  final pageCount = (lines.length / linesPerPage).ceil().clamp(1, 999);

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

String _sanitizeUnsupportedChars(String text) {
  // Strip Latin Extended + currency symbols not covered by bundled fonts.
  final unsupported = RegExp(r'[\u0100-\u017F\u20A0-\u20CF]');
  return text.replaceAll(unsupported, '');
}
