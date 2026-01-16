import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// PDF 내보내기 유틸리티
class PdfExportUtils {
  /// CSV 데이터를 PDF로 변환
  static Future<Uint8List> convertCsvToPdf({
    required List<dynamic>? headerRow,
    required List<List<dynamic>> dataRows,
    required String title,
  }) async {
    final pdf = pw.Document();

    // 한글 폰트 로드 (Korean + Latin)
    final fontData = await rootBundle.load(
      'assets/fonts/NotoSansKR-Regular.ttf',
    );
    final font = pw.Font.ttf(fontData);

    // 테이블 데이터 준비
    final tableData = <List<String>>[];

    // 헤더 추가
    if (headerRow != null) {
      tableData.add(headerRow.map((cell) => cell.toString()).toList());
    }

    // 데이터 행 추가
    for (final row in dataRows) {
      tableData.add(row.map((cell) => cell.toString()).toList());
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              context: context,
              data: tableData,
              headerStyle: pw.TextStyle(
                font: font,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              cellStyle: pw.TextStyle(font: font, fontSize: 10),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey700,
              ),
              cellHeight: 30,
              cellAlignments: {
                for (var i = 0; i < (headerRow?.length ?? 0); i++)
                  i: pw.Alignment.centerLeft,
              },
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// PDF를 임시 파일로 저장하고 경로 반환
  static Future<String> savePdfToTemp(
    Uint8List pdfBytes,
    String fileName,
  ) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final baseName = p.basenameWithoutExtension(fileName);
    final outputFile = File('${tempDir.path}/${baseName}_$timestamp.pdf');

    await outputFile.writeAsBytes(pdfBytes, flush: true);
    return outputFile.path;
  }

  /// PDF 내보내기 다이얼로그 표시
  static Future<void> showExportDialog({
    required BuildContext context,
    required Future<Uint8List> Function() generatePdf,
    required String fileName,
    required VoidCallback onSuccess,
  }) async {
    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('PDF 생성 중...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // PDF 생성
      final pdfBytes = await generatePdf();

      // 임시 파일로 저장
      final pdfPath = await savePdfToTemp(pdfBytes, fileName);

      if (context.mounted) {
        // 로딩 다이얼로그 닫기
        Navigator.of(context).pop();

        // 성공 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF로 저장되었습니다: ${p.basename(pdfPath)}'),
            action: SnackBarAction(label: '열기', onPressed: onSuccess),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        // 로딩 다이얼로그 닫기
        Navigator.of(context).pop();

        // 에러 다이얼로그
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('PDF 생성 실패'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    }
  }
}
