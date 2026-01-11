import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

import '../../core/widgets/app_loading.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({
    super.key,
    required this.assetPath,
    required this.title,
    this.isAsset = true,
  });

  final String assetPath;
  final String title;
  final bool isAsset;

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  PdfControllerPinch? _controller;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoading = true;
  String? _error;

  // Page jump mode
  bool _isPageJumpMode = false;
  final _pageInputController = TextEditingController();
  final _pageInputFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initPdf();
  }

  Future<void> _initPdf() async {
    try {
      PdfDocument document;
      if (widget.isAsset) {
        // Asset 파일을 임시 파일로 복사 후 로드
        final byteData = await rootBundle.load(widget.assetPath);
        final tempDir = await getTemporaryDirectory();
        final fileName = widget.assetPath.split('/').last;
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(byteData.buffer.asUint8List());
        document = await PdfDocument.openFile(tempFile.path);
      } else {
        document = await PdfDocument.openFile(widget.assetPath);
      }

      setState(() {
        _controller = PdfControllerPinch(document: Future.value(document));
        _totalPages = document.pagesCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _pageInputController.dispose();
    _pageInputFocusNode.dispose();
    super.dispose();
  }

  void _togglePageJumpMode() {
    setState(() {
      _isPageJumpMode = !_isPageJumpMode;
      if (_isPageJumpMode) {
        _pageInputController.text = _currentPage.toString();
        // Focus and select all text after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _pageInputFocusNode.requestFocus();
          _pageInputController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _pageInputController.text.length,
          );
        });
      } else {
        _pageInputController.clear();
      }
    });
  }

  void _jumpToPage() {
    final pageNum = int.tryParse(_pageInputController.text);
    if (pageNum != null && pageNum >= 1 && pageNum <= _totalPages) {
      _controller?.jumpToPage(pageNum);
      _togglePageJumpMode();
    } else {
      // Invalid page - shake or show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('1 ~ $_totalPages 사이의 페이지를 입력하세요'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AppLoading();
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                'PDF를 열 수 없습니다',
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
      );
    }

    return Column(
      children: [
        Expanded(
          child: PdfViewPinch(
            controller: _controller!,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
              options: const DefaultBuilderOptions(),
              documentLoaderBuilder: (_) =>
                  const Center(child: CircularProgressIndicator()),
              pageLoaderBuilder: (_) =>
                  const Center(child: CircularProgressIndicator()),
              errorBuilder: (_, error) => Center(child: Text(error.toString())),
            ),
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: _isPageJumpMode ? _buildPageJumpBar() : _buildNavigationBar(),
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Row(
      key: const ValueKey('navigation'),
      children: [
        // Left spacer for balance
        const SizedBox(width: 40),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 1
                    ? () => _controller?.previousPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      )
                    : null,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage < _totalPages
                    ? () => _controller?.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeIn,
                      )
                    : null,
                color: Colors.grey.shade700,
              ),
            ],
          ),
        ),
        // Page jump button on the right
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _togglePageJumpMode,
          color: Colors.grey.shade600,
          tooltip: '페이지 이동',
        ),
      ],
    );
  }

  Widget _buildPageJumpBar() {
    return Row(
      key: const ValueKey('pageJump'),
      children: [
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(
                  Icons.description_outlined,
                  size: 20,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _pageInputController,
                    focusNode: _pageInputFocusNode,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.go,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                    decoration: InputDecoration(
                      hintText: '1 ~ $_totalPages',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onSubmitted: (_) => _jumpToPage(),
                  ),
                ),
                Text(
                  '/ $_totalPages',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _jumpToPage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Close button
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: _togglePageJumpMode,
          color: Colors.grey.shade600,
          tooltip: '닫기',
        ),
      ],
    );
  }
}
