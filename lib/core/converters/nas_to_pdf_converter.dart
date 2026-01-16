import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import 'document_converter.dart';

/// NAS API를 통해 HWP/HWPX/PPTX를 PDF로 변환하는 컨버터
class NasToPdfConverter implements DocumentConverter {
  /// 지원하는 파일 타입
  static const supportedTypes = ['hwp', 'hwpx', 'pptx'];

  /// HWP/HWPX 변환 엔드포인트 (Flask)
  static const _hwpUrl = 'https://kkomjang.synology.me:4000/convert';

  /// PPTX 변환 엔드포인트 (Gotenberg)
  static const _pptxUrl = 'https://kkomjang.synology.me:4001/forms/libreoffice/convert';

  @override
  String get converterType => 'nas';

  @override
  Future<Uint8List> convertToPdf(String filePath, {bool isAsset = false}) async {
    // 1. 파일 로드
    final fileBytes = await _loadSourceBytes(filePath, isAsset);

    // 2. 파일 확장자에 따라 적절한 엔드포인트 선택
    final ext = p.extension(filePath).toLowerCase().replaceFirst('.', '');
    final url = _getEndpointUrl(ext);

    // 3. NAS API 호출
    final fileName = p.basename(filePath);
    return _requestConversion(fileBytes, fileName, url);
  }

  String _getEndpointUrl(String extension) {
    switch (extension) {
      case 'hwp':
      case 'hwpx':
        return _hwpUrl;
      case 'pptx':
        return _pptxUrl;
      default:
        throw UnsupportedError('지원하지 않는 파일 형식입니다: $extension');
    }
  }

  Future<Uint8List> _loadSourceBytes(String filePath, bool isAsset) async {
    if (isAsset) {
      final byteData = await rootBundle.load(filePath);
      return byteData.buffer.asUint8List();
    }

    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('파일을 찾을 수 없습니다.');
    }
    return file.readAsBytes();
  }

  Future<Uint8List> _requestConversion(
    Uint8List fileBytes,
    String fileName,
    String url,
  ) async {
    final boundary = 'kkomi-boundary-${DateTime.now().millisecondsSinceEpoch}';
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client.postUrl(Uri.parse(url));
      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'multipart/form-data; boundary=$boundary',
      );

      request.add(utf8.encode('--$boundary\r\n'));
      request.add(
        utf8.encode(
          'Content-Disposition: form-data; name="file"; '
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
}
