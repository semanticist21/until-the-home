import 'dart:io';

import 'package:docx_file_viewer/docx_file_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/widgets/app_loading.dart';
import '../../core/widgets/search_bottom_bar.dart';

class DocxViewerScreen extends StatefulWidget {
  const DocxViewerScreen({
    super.key,
    required this.filePath,
    required this.title,
    this.isAsset = false,
  });

  final String filePath;
  final String title;
  final bool isAsset;

  @override
  State<DocxViewerScreen> createState() => _DocxViewerScreenState();
}

class _DocxViewerScreenState extends State<DocxViewerScreen> {
  File? _file;
  bool _isFileReady = false;
  bool _isDocxParsing = true;
  String? _error;
  bool _showSearchInput = false;
  final _searchController = DocxSearchController();
  final _searchTextController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 네비게이션 애니메이션 완료 후 파일 로드 시작 (~300ms)
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _prepareFile();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchTextController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _prepareFile() async {
    try {
      if (widget.isAsset) {
        final byteData = await rootBundle.load(widget.filePath);
        final tempDir = await getTemporaryDirectory();
        final fileName = widget.filePath.split('/').last;
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(byteData.buffer.asUint8List());
        setState(() {
          _file = tempFile;
          _isFileReady = true;
        });
      } else {
        setState(() {
          _file = File(widget.filePath);
          _isFileReady = true;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isFileReady = true;
        _isDocxParsing = false;
      });
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
      );
    }

    if (!_isFileReady) {
      return const AppLoading();
    }

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: DocxView(
                file: _file!,
                searchController: _searchController,
                config: DocxViewConfig(
                  enableZoom: true,
                  enableSearch: true,
                  enableSelection: true,
                  pageMode: DocxPageMode.continuous,
                  pageWidth: 360,
                  minScale: 0.5,
                  maxScale: 4.0,
                  backgroundColor: Colors.grey.shade200,
                  showPageBreaks: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onLoaded: () {
                  debugPrint('[DOCX_VIEWER] onLoaded called - removing overlay');
                  debugPrint('[DOCX_VIEWER] Current state: _isDocxParsing=$_isDocxParsing, _error=$_error');
                  // Add slight delay to ensure DocxView is fully rendered before removing overlay
                  Future.delayed(const Duration(milliseconds: 50), () {
                    if (mounted) {
                      setState(() {
                        _isDocxParsing = false;
                      });
                      debugPrint('[DOCX_VIEWER] Overlay removed, DocxView now visible');
                    }
                  });
                },
                onError: (error) {
                  debugPrint('[DOCX_VIEWER] onError called: $error');
                  setState(() {
                    _error = error.toString();
                  });
                },
              ),
            ),
            _buildBottomBar(),
          ],
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: _isDocxParsing
              ? const AppLoadingOverlay()
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return ListenableBuilder(
      listenable: _searchController,
      builder: (context, _) {
        return SearchBottomBar(
          showSearchInput: _showSearchInput,
          searchController: _searchTextController,
          searchFocusNode: _searchFocusNode,
          onSearchChanged: (value) {
            if (value.isNotEmpty) {
              _searchController.search(value);
            } else {
              _searchController.clear();
            }
          },
          onSearchToggle: () {
            setState(() {
              _showSearchInput = true;
            });
            _searchFocusNode.requestFocus();
          },
          onSearchClose: () {
            setState(() {
              _showSearchInput = false;
              _searchTextController.clear();
              _searchController.clear();
            });
          },
          matchCount: _searchController.matchCount,
          currentMatchIndex: _searchController.currentMatchIndex,
          onPreviousMatch: () => _searchController.previousMatch(),
          onNextMatch: () => _searchController.nextMatch(),
        );
      },
    );
  }
}
