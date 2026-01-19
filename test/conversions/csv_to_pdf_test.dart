import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kkomi/core/utils/pdf_export_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CSV to PDF Conversion Tests', () {
    test('Convert simple CSV with header to PDF', () async {
      const csvContent = '''Name,Age,City
John,25,Seoul
Jane,30,Busan
Bob,35,Incheon''';

      final csvData = const CsvToListConverter().convert(csvContent);
      final headerRow = csvData.isNotEmpty ? csvData.first : null;
      final dataRows = csvData.length > 1
          ? csvData.sublist(1)
          : <List<dynamic>>[];

      final pdfBytes = await PdfExportUtils.convertCsvToPdf(
        headerRow: headerRow,
        dataRows: dataRows,
        title: 'Test CSV',
      );

      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(100));

      // Verify PDF header
      final header = String.fromCharCodes(pdfBytes.take(5));
      expect(header, equals('%PDF-'));
    });

    test('Convert CSV without header to PDF', () async {
      const csvContent = '''John,25,Seoul
Jane,30,Busan''';

      final csvData = const CsvToListConverter().convert(csvContent);

      final pdfBytes = await PdfExportUtils.convertCsvToPdf(
        headerRow: null,
        dataRows: csvData,
        title: 'No Header CSV',
      );

      expect(pdfBytes, isNotEmpty);

      // Verify PDF header
      final header = String.fromCharCodes(pdfBytes.take(5));
      expect(header, equals('%PDF-'));
    });

    test('Convert large CSV (multiple pages) to PDF', () async {
      // Create CSV with 100 rows
      final buffer = StringBuffer('ID,Name,Value\n');
      for (var i = 1; i <= 100; i++) {
        buffer.write('$i,Item$i,${i * 10}\n');
      }

      final csvData = const CsvToListConverter().convert(buffer.toString());
      final headerRow = csvData.first;
      final dataRows = csvData.sublist(1);

      final pdfBytes = await PdfExportUtils.convertCsvToPdf(
        headerRow: headerRow,
        dataRows: dataRows,
        title: 'Large CSV',
      );

      expect(pdfBytes, isNotEmpty);
      expect(
        pdfBytes.length,
        greaterThan(1000),
      ); // Large table should be bigger

      // Verify PDF header
      final header = String.fromCharCodes(pdfBytes.take(5));
      expect(header, equals('%PDF-'));
    });

    test('Convert CSV with Korean text to PDF', () async {
      const csvContent = '''이름,나이,도시
홍길동,25,서울
김철수,30,부산''';

      final csvData = const CsvToListConverter().convert(csvContent);
      final headerRow = csvData.first;
      final dataRows = csvData.sublist(1);

      final pdfBytes = await PdfExportUtils.convertCsvToPdf(
        headerRow: headerRow,
        dataRows: dataRows,
        title: '한글 CSV',
      );

      expect(pdfBytes, isNotEmpty);

      // Verify PDF header
      final header = String.fromCharCodes(pdfBytes.take(5));
      expect(header, equals('%PDF-'));
    });

    test('Convert empty CSV to PDF', () async {
      final pdfBytes = await PdfExportUtils.convertCsvToPdf(
        headerRow: null,
        dataRows: [],
        title: 'Empty CSV',
      );

      expect(pdfBytes, isNotEmpty);

      // Verify PDF header
      final header = String.fromCharCodes(pdfBytes.take(5));
      expect(header, equals('%PDF-'));
    });

    test('Convert sample.csv from test_samples', () async {
      final csvContent = await File('test_samples/sample.csv').readAsString();

      expect(csvContent, isNotEmpty);

      final csvData = const CsvToListConverter().convert(csvContent);
      final headerRow = csvData.isNotEmpty ? csvData.first : null;
      final dataRows = csvData.length > 1
          ? csvData.sublist(1)
          : <List<dynamic>>[];

      final pdfBytes = await PdfExportUtils.convertCsvToPdf(
        headerRow: headerRow,
        dataRows: dataRows,
        title: 'sample.csv',
      );

      expect(pdfBytes, isNotEmpty);

      // Verify PDF header
      final header = String.fromCharCodes(pdfBytes.take(5));
      expect(header, equals('%PDF-'));
    });

    test(
      'Save PDF to temp directory',
      () async {
        const csvContent = '''Name,Value
Test,123''';

        final csvData = const CsvToListConverter().convert(csvContent);
        final headerRow = csvData.first;
        final dataRows = csvData.sublist(1);

        final pdfBytes = await PdfExportUtils.convertCsvToPdf(
          headerRow: headerRow,
          dataRows: dataRows,
          title: 'Test',
        );

        final tempPath = await PdfExportUtils.savePdfToTemp(
          pdfBytes,
          'test.csv',
        );

        expect(tempPath, isNotEmpty);
        expect(tempPath.endsWith('.pdf'), isTrue);
      },
      skip:
          'Requires path_provider plugin - better suited for integration tests',
    );
  });
}
