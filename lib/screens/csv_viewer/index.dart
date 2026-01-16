import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/pdf_export_utils.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/common_pdf_viewer.dart';

class CsvViewerScreen extends StatefulWidget {
  const CsvViewerScreen({
    super.key,
    required this.filePath,
    required this.title,
    this.isAsset = false,
  });

  final String filePath;
  final String title;
  final bool isAsset;

  @override
  State<CsvViewerScreen> createState() => _CsvViewerScreenState();
}

class _CsvViewerScreenState extends State<CsvViewerScreen> {
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  String? _error;

  // CSV 데이터 저장 (PDF 내보내기용)
  List<dynamic>? _headerRow;
  List<List<dynamic>>? _dataRows;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _loadAndConvert();
    });
  }

  Future<void> _loadAndConvert() async {
    try {
      // 1. CSV 파일 읽기
      String csvContent;
      if (widget.isAsset) {
        csvContent = await rootBundle.loadString(widget.filePath);
      } else {
        csvContent = await File(widget.filePath).readAsString();
      }

      final normalizedContent = csvContent
          .replaceAll('\r\n', '\n')
          .replaceAll('\r', '\n');
      final data = const CsvToListConverter(
        eol: '\n',
      ).convert(normalizedContent);

      // CSV 데이터 저장 (PDF 내보내기용)
      if (data.isNotEmpty) {
        _headerRow = data.first;
        _dataRows = data.length > 1 ? data.skip(1).toList() : [];
      } else {
        _headerRow = null;
        _dataRows = [];
      }

      // 2. PDF로 변환
      final pdfBytes = await PdfExportUtils.convertCsvToPdf(
        headerRow: _headerRow,
        dataRows: _dataRows ?? [],
        title: widget.title,
      );

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
