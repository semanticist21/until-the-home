import 'dart:io';

import 'package:docx_file_viewer/docx_file_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

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
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('문서 로딩 중...'),
          ],
        ),
      );
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
                  debugPrint('DOCX loaded successfully');
                  setState(() {
                    _isDocxParsing = false;
                  });
                },
                onError: (error) {
                  setState(() {
                    _error = error.toString();
                  });
                },
              ),
            ),
            _buildBottomBar(),
          ],
        ),
        if (_isDocxParsing)
          Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('문서 파싱 중...'),
                ],
              ),
            ),
          ),
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
        child: _showSearchInput ? _buildSearchInput() : _buildSearchButton(),
      ),
    );
  }

  Widget _buildSearchButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _showSearchInput = true;
            });
            _searchFocusNode.requestFocus();
          },
          color: Colors.grey.shade700,
        ),
      ],
    );
  }

  Widget _buildSearchInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchTextController,
            focusNode: _searchFocusNode,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '검색...',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade500),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                _searchController.search(value);
              } else {
                _searchController.clear();
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        ListenableBuilder(
          listenable: _searchController,
          builder: (context, _) {
            final matchCount = _searchController.matchCount;
            final currentIndex = _searchController.currentMatchIndex;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (matchCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${currentIndex + 1} / $matchCount',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_up, size: 20),
                  onPressed: matchCount > 0
                      ? () => _searchController.previousMatch()
                      : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  color: Colors.grey.shade700,
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                  onPressed: matchCount > 0
                      ? () => _searchController.nextMatch()
                      : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  color: Colors.grey.shade700,
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    setState(() {
                      _showSearchInput = false;
                      _searchTextController.clear();
                      _searchController.clear();
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  color: Colors.grey.shade700,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
