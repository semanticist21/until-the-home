import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/data/recent_documents_store.dart';
import '../../core/widgets/app_loading.dart';
import '../pdf_viewer/index.dart';

bool openRecentDocumentHwp(BuildContext context, RecentDocument doc) {
  if (doc.type != 'HWP') {
    return false;
  }

  return openRecentDocumentHwpLike(context, doc);
}

bool openRecentDocumentHwpLike(BuildContext context, RecentDocument doc) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _HwpPdfViewerScreen(
        filePath: doc.path,
        title: doc.name,
        isAsset: _isAssetPath(doc.path),
      ),
    ),
  );
  return true;
}

bool _isAssetPath(String path) {
  try {
    return !File(path).existsSync();
  } catch (_) {
    return true;
  }
}

class _HwpPdfViewerScreen extends StatefulWidget {
  const _HwpPdfViewerScreen({
    required this.filePath,
    required this.title,
    required this.isAsset,
  });

  final String filePath;
  final String title;
  final bool isAsset;

  @override
  State<_HwpPdfViewerScreen> createState() => _HwpPdfViewerScreenState();
}

class _HwpPdfViewerScreenState extends State<_HwpPdfViewerScreen> {
  static const _gotenbergUrl =
      'https://kkomjang.synology.me:4000/forms/libreoffice/convert';

  bool _isConverting = true;
  String? _errorMessage;
  String? _errorDetails;
  String? _convertedPath;

  @override
  void initState() {
    super.initState();
    _convertToPdf();
  }

  Future<void> _convertToPdf() async {
    setState(() {
      _isConverting = true;
      _errorMessage = null;
      _errorDetails = null;
    });

    try {
      final fileBytes = await _loadSourceBytes();
      final fileName = p.basename(widget.filePath);
      final pdfBytes = await _requestConversion(fileBytes, fileName);
      final tempDir = await getTemporaryDirectory();
      final baseName = p.basenameWithoutExtension(fileName);
      final outputFile = File(
        '${tempDir.path}/${baseName}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await outputFile.writeAsBytes(pdfBytes, flush: true);

      if (!mounted) {
        return;
      }
      setState(() {
        _convertedPath = outputFile.path;
        _isConverting = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        final parsed = _parseErrorMessage(e.toString());
        _errorMessage = parsed.message;
        _errorDetails = parsed.details;
        _isConverting = false;
      });
    }
  }

  Future<Uint8List> _loadSourceBytes() async {
    if (widget.isAsset) {
      final byteData = await rootBundle.load(widget.filePath);
      return byteData.buffer.asUint8List();
    }

    final file = File(widget.filePath);
    if (!await file.exists()) {
      throw Exception('파일을 찾을 수 없습니다.');
    }
    return file.readAsBytes();
  }

  Future<Uint8List> _requestConversion(
    Uint8List fileBytes,
    String fileName,
  ) async {
    final boundary = 'kkomi-boundary-${DateTime.now().millisecondsSinceEpoch}';
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client.postUrl(Uri.parse(_gotenbergUrl));
      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'multipart/form-data; boundary=$boundary',
      );

      request.add(utf8.encode('--$boundary\r\n'));
      request.add(
        utf8.encode(
          'Content-Disposition: form-data; name="files"; '
          'filename="$fileName"\r\n',
        ),
      );
      request.add(
        utf8.encode('Content-Type: application/octet-stream\r\n\r\n'),
      );
      request.add(fileBytes);
      request.add(utf8.encode('\r\n--$boundary--\r\n'));

      final response = await request.close().timeout(
        const Duration(seconds: 20),
      );
      final responseBytes = await _readResponseBytes(
        response,
      ).timeout(const Duration(seconds: 20));
      if (response.statusCode != HttpStatus.ok) {
        throw Exception(
          '변환 실패 (${response.statusCode}): ${utf8.decode(responseBytes)}',
        );
      }
      return responseBytes;
    } finally {
      client.close(force: true);
    }
  }

  Future<Uint8List> _readResponseBytes(HttpClientResponse response) async {
    final buffer = BytesBuilder();
    await for (final chunk in response) {
      buffer.add(chunk);
    }
    return buffer.takeBytes();
  }

  @override
  Widget build(BuildContext context) {
    if (_convertedPath != null) {
      return PdfViewerScreen(
        assetPath: _convertedPath!,
        title: widget.title,
        isAsset: false,
      );
    }

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
      body: _isConverting ? const AppLoading() : _buildError(),
    );
  }

  Widget _buildError() {
    if (_errorMessage == null) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'HWP 변환에 실패했습니다',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            if (_errorDetails != null) ...[
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 120),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _errorDetails!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            _RetryButton(onTap: _convertToPdf),
          ],
        ),
      ),
    );
  }

  _ParsedError _parseErrorMessage(String raw) {
    final statusMatch = RegExp(r'변환 실패 \((\d+)\)').firstMatch(raw);
    final statusCode = statusMatch != null
        ? int.tryParse(statusMatch.group(1)!)
        : null;
    final detailsMatch = RegExp(r'\):\s*(.*)$', dotAll: true).firstMatch(raw);
    final details = detailsMatch?.group(1) ?? raw;

    String message;
    switch (statusCode) {
      case 400:
        message = '문서가 손상되었거나 암호가 설정된 파일일 수 있어요.';
        break;
      case 413:
        message = '파일 크기가 너무 커서 변환할 수 없어요.';
        break;
      case 500:
        message = '서버에서 변환에 실패했어요. 잠시 후 다시 시도해 주세요.';
        break;
      default:
        message = '서버 연결 또는 문서 처리 중 문제가 발생했어요.';
    }

    return _ParsedError(message: message, details: details);
  }
}

class _ParsedError {
  const _ParsedError({required this.message, required this.details});

  final String message;
  final String? details;
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            '다시 시도',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}
