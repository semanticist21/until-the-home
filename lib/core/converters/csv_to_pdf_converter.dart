import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../utils/pdf_export_utils.dart';
import 'document_converter.dart';

/// CSV 파일을 PDF로 변환하는 컨버터
class CsvToPdfConverter implements DocumentConverter {
  @override
  String get converterType => 'csv';

  @override
  Future<Uint8List> convertToPdf(
    String filePath, {
    bool isAsset = false,
  }) async {
    // 1. CSV 파일 읽기
    String csvContent;
    if (isAsset) {
      csvContent = await rootBundle.loadString(filePath);
    } else {
      csvContent = await File(filePath).readAsString();
    }

    // 2. CSV 파싱
    final normalizedContent = csvContent
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');
    final data = const CsvToListConverter(eol: '\n').convert(normalizedContent);

    // CSV 데이터 분리
    List<dynamic>? headerRow;
    List<List<dynamic>> dataRows = [];

    if (data.isNotEmpty) {
      headerRow = data.first;
      dataRows = data.length > 1 ? data.skip(1).toList() : [];
    }

    // 3. PDF로 변환
    final title = p.basenameWithoutExtension(filePath);
    return PdfExportUtils.convertCsvToPdf(
      headerRow: headerRow,
      dataRows: dataRows,
      title: title,
    );
  }
}
