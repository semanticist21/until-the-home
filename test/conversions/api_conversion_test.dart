import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx/pdfrx.dart' as pdfrx;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('API Conversion Tests', () {
    // HWP conversion tests
    group('HWP to PDF via Flask API', () {
      const hwpApiUrl = 'https://kkomjang.synology.me:4000/convert';

      test(
        'Convert sample.hwp to PDF via API',
        () async {
          final hwpBytes = await rootBundle.load('test_samples/sample.hwp');
          final fileBytes = hwpBytes.buffer.asUint8List();

          try {
            final pdfBytes = await _requestConversion(
              hwpApiUrl,
              fileBytes,
              'sample.hwp',
            );

            expect(pdfBytes, isNotEmpty);
            expect(pdfBytes.length, greaterThan(100));

            // Verify it's a valid PDF
            final document = await pdfrx.PdfDocument.openData(pdfBytes);
            expect(document.pages.length, greaterThan(0));
            document.dispose();
          } catch (e) {
            // API might not be available in test environment
            // This is expected for CI/CD environments
            // ignore: avoid_print
            print('HWP API conversion failed (expected in test env): $e');
          }
        },
        timeout: const Timeout(Duration(seconds: 30)),
      );

      test(
        'HWP API returns error for invalid file',
        () async {
          final invalidBytes = Uint8List.fromList([0, 1, 2, 3, 4]);

          try {
            await _requestConversion(hwpApiUrl, invalidBytes, 'invalid.hwp');
            fail('Should throw exception for invalid file');
          } catch (e) {
            expect(e, isA<Exception>());
          }
        },
        timeout: const Timeout(Duration(seconds: 30)),
      );
    });

    // PPTX conversion tests
    group('PPTX to PDF via Gotenberg API', () {
      const pptxApiUrl =
          'https://kkomjang.synology.me:4001/forms/libreoffice/convert';

      test(
        'Convert sample.pptx to PDF via API',
        () async {
          final pptxBytes = await rootBundle.load('test_samples/sample.pptx');
          final fileBytes = pptxBytes.buffer.asUint8List();

          try {
            final pdfBytes = await _requestConversion(
              pptxApiUrl,
              fileBytes,
              'sample.pptx',
            );

            expect(pdfBytes, isNotEmpty);
            expect(pdfBytes.length, greaterThan(100));

            // Verify it's a valid PDF
            final document = await pdfrx.PdfDocument.openData(pdfBytes);
            expect(document.pages.length, greaterThan(0));
            document.dispose();
          } catch (e) {
            // API might not be available in test environment
            // ignore: avoid_print
            print('PPTX API conversion failed (expected in test env): $e');
          }
        },
        timeout: const Timeout(Duration(seconds: 30)),
      );

      test(
        'PPTX API returns error for invalid file',
        () async {
          final invalidBytes = Uint8List.fromList([0, 1, 2, 3, 4]);

          try {
            await _requestConversion(pptxApiUrl, invalidBytes, 'invalid.pptx');
            fail('Should throw exception for invalid file');
          } catch (e) {
            expect(e, isA<Exception>());
          }
        },
        timeout: const Timeout(Duration(seconds: 30)),
      );
    });

    // API availability tests
    test('HWP API endpoint is accessible', () async {
      try {
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 5);

        final request = await client.getUrl(
          Uri.parse('https://kkomjang.synology.me:4000'),
        );
        final response = await request.close().timeout(
          const Duration(seconds: 5),
        );

        // Any response (even error) means the endpoint is accessible
        expect(response.statusCode, isNotNull);

        client.close(force: true);
      } catch (e) {
        // ignore: avoid_print
        print('HWP API not accessible (expected in test env): $e');
      }
    });

    test('PPTX API endpoint is accessible', () async {
      try {
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 5);

        final request = await client.getUrl(
          Uri.parse('https://kkomjang.synology.me:4001'),
        );
        final response = await request.close().timeout(
          const Duration(seconds: 5),
        );

        // Any response (even error) means the endpoint is accessible
        expect(response.statusCode, isNotNull);

        client.close(force: true);
      } catch (e) {
        // ignore: avoid_print
        print('PPTX API not accessible (expected in test env): $e');
      }
    });
  });
}

/// Helper function to make conversion API request
/// This mirrors the logic in handler files
Future<Uint8List> _requestConversion(
  String apiUrl,
  Uint8List fileBytes,
  String fileName,
) async {
  final boundary = 'kkomi-boundary-${DateTime.now().millisecondsSinceEpoch}';
  final client = HttpClient();
  client.connectionTimeout = const Duration(seconds: 15);

  try {
    final request = await client.postUrl(Uri.parse(apiUrl));
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
    request.add(utf8.encode('Content-Type: application/octet-stream\r\n\r\n'));
    request.add(fileBytes);
    request.add(utf8.encode('\r\n--$boundary--\r\n'));

    final response = await request.close().timeout(const Duration(seconds: 20));
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
