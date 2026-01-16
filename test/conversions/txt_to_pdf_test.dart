import 'package:flutter/services.dart';
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
      final textContent = await rootBundle.loadString(
        'test_samples/sample.txt',
      );

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

  // Load multi-language fonts (simplified for testing - only Korean)
  final fontData = await rootBundle.load('assets/fonts/NotoSansKR-Regular.ttf');
  final font = pw.Font.ttf(fontData);

  // Split text into lines
  final lines = text.split('\n');

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
