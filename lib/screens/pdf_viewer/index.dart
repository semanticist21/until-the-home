import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({
    super.key,
    required this.assetPath,
    required this.title,
  });

  final String assetPath;
  final String title;

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final _controller = PdfViewerController();
  int _currentPage = 1;
  int _totalPages = 0;

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
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () => _controller.zoomDown(),
            tooltip: '축소',
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () => _controller.zoomUp(),
            tooltip: '확대',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PdfViewer.asset(
              widget.assetPath,
              controller: _controller,
              params: PdfViewerParams(
                backgroundColor: Colors.grey.shade200,
                // 페이지 너비에 맞춤 (가로 모드에서도 적절한 크기)
                calculateInitialZoom:
                    (document, controller, fitZoom, coverZoom) {
                      return coverZoom;
                    },
                // 화면 회전 시 현재 페이지 너비에 맞춤
                onViewSizeChanged: (viewSize, oldViewSize, controller) {
                  if (oldViewSize != null) {
                    // 프레임 완료 후 + 200ms 딜레이 (공식 문서 권장)
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Future.delayed(const Duration(milliseconds: 200), () {
                        if (!mounted) return;
                        final matrix = controller.calcMatrixFitWidthForPage(
                          pageNumber: _currentPage,
                        );
                        if (matrix != null) {
                          controller.goTo(matrix);
                        }
                      });
                    });
                  }
                },
                onViewerReady: (document, controller) {
                  setState(() {
                    _totalPages = document.pages.length;
                  });
                },
                onPageChanged: (pageNumber) {
                  setState(() {
                    _currentPage = pageNumber ?? 1;
                  });
                },
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _currentPage > 1
                  ? () => _controller.goToPage(pageNumber: _currentPage - 1)
                  : null,
              color: Colors.grey.shade700,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  ? () => _controller.goToPage(pageNumber: _currentPage + 1)
                  : null,
              color: Colors.grey.shade700,
            ),
          ],
        ),
      ),
    );
  }
}
