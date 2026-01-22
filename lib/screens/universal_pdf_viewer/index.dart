import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../core/converters/document_converter.dart';
import '../../core/data/pdf_cache_store.dart';
import '../../core/utils/app_logger.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/app_server_conversion_loading.dart';
import '../../core/widgets/common_pdf_viewer.dart';

/// 통합 PDF 뷰어
///
/// - PDF 파일을 직접 표시하거나
/// - DocumentConverter를 사용하여 다른 형식을 PDF로 변환 후 표시
class UniversalPdfViewer extends StatefulWidget {
  const UniversalPdfViewer({
    super.key,
    required this.filePath,
    required this.title,
    this.isAsset = false,
    this.converter,
  });

  /// 원본 파일 경로 (asset 또는 실제 파일 경로)
  final String filePath;

  /// 화면 제목
  final String title;

  /// asset 파일 여부
  final bool isAsset;

  /// PDF 변환기 (null이면 직접 PDF 파일)
  final DocumentConverter? converter;

  @override
  State<UniversalPdfViewer> createState() => _UniversalPdfViewerState();
}

class _UniversalPdfViewerState extends State<UniversalPdfViewer> {
  bool _isConverting = true;
  String? _errorMessage;
  String? _errorDetails;
  Uint8List? _pdfBytes;
  String? _convertedPdfPath;

  @override
  void initState() {
    super.initState();
    _loadOrConvert();
  }

  Future<void> _loadOrConvert() async {
    setState(() {
      _isConverting = true;
      _errorMessage = null;
      _errorDetails = null;
    });

    try {
      if (widget.converter != null) {
        // 변환이 필요한 경우 - 먼저 캐시 확인
        Uint8List? pdfBytes;

        // 캐시 확인 (asset은 캐시 제외)
        if (!widget.isAsset) {
          pdfBytes = await PdfCacheStore.instance.getCachedPdf(widget.filePath);
          if (pdfBytes != null) {
            appLogger.i(
              '[UniversalPdfViewer] Using cached PDF: ${widget.filePath}',
            );
          }
        }

        // 캐시가 없으면 변환 수행
        if (pdfBytes == null) {
          appLogger.i(
            '[UniversalPdfViewer] Converting document: ${widget.filePath}',
          );
          pdfBytes = await widget.converter!.convertToPdf(
            widget.filePath,
            isAsset: widget.isAsset,
          );

          // 변환 성공 시 캐시 저장 (asset은 캐시 제외)
          if (!widget.isAsset) {
            await PdfCacheStore.instance.savePdfToCache(
              widget.filePath,
              pdfBytes,
            );
          }
        }

        // 변환된 PDF를 임시 파일로 저장
        final tempDir = await getTemporaryDirectory();
        final baseName = p.basenameWithoutExtension(widget.filePath);
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final outputFile = File('${tempDir.path}/${baseName}_$timestamp.pdf');
        await outputFile.writeAsBytes(pdfBytes, flush: true);

        if (!mounted) return;

        setState(() {
          _pdfBytes = pdfBytes;
          _convertedPdfPath = outputFile.path;
          _isConverting = false;
        });
      } else {
        // 직접 PDF 파일인 경우 - 변환 불필요
        setState(() {
          _isConverting = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        final parsed = _parseErrorMessage(e.toString());
        _errorMessage = parsed.message;
        _errorDetails = parsed.details;
        _isConverting = false;
      });
    }
  }

  Future<void> _savePdf() async {
    if (_pdfBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF 생성 중입니다. 잠시 후 다시 시도하세요.')),
      );
      return;
    }

    try {
      final outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'PDF 저장',
        fileName: '${p.basenameWithoutExtension(widget.title)}.pdf',
        bytes: _pdfBytes, // iOS/Android에서는 이것만으로 저장 완료
      );

      if (outputPath == null) {
        // 사용자가 취소
        return;
      }

      // Desktop platforms만 추가 저장 필요 (iOS/Android는 bytes로 자동 저장됨)
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final file = File(outputPath);
        await file.writeAsBytes(_pdfBytes!, flush: true);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF가 저장되었습니다: ${p.basename(outputPath)}')),
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
    // 변환 완료 후 PDF 뷰어 표시
    if (!_isConverting && _errorMessage == null) {
      if (widget.converter != null && _convertedPdfPath != null) {
        // 변환된 PDF 표시
        return CommonPdfViewer(
          filePath: _convertedPdfPath!,
          title: widget.title,
          onSave: _savePdf,
        );
      } else if (widget.converter == null) {
        // 원본 PDF 표시
        if (widget.isAsset) {
          return CommonPdfViewer(
            assetPath: widget.filePath,
            title: widget.title,
          );
        } else {
          return CommonPdfViewer(
            filePath: widget.filePath,
            title: widget.title,
          );
        }
      }
    }

    // 로딩 또는 에러 화면
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
      body: _isConverting ? _buildLoading() : _buildError(),
    );
  }

  Widget _buildLoading() {
    final isServerConversion = widget.converter?.converterType == 'nas';
    return isServerConversion
        ? const AppServerConversionLoading()
        : const AppLoading();
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
              '변환에 실패했습니다',
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
            _RetryButton(onTap: _loadOrConvert),
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
