import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/pdf_export_utils.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/search_bottom_bar.dart';
import '../pdf_viewer/index.dart';

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
  List<dynamic>? _headerRow;
  List<List<dynamic>>? _dataRows;
  bool _isLoading = true;
  String? _error;

  // Search
  bool _showSearchInput = false;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  String _searchQuery = '';
  int _matchCount = 0;
  List<({int row, int col})> _matchPositions = [];
  int? _currentMatchIndex;
  final _verticalScrollController = ScrollController();
  final _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _loadCsv();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCsv() async {
    try {
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

      setState(() {
        if (data.isNotEmpty) {
          _headerRow = data.first;
          _dataRows = data.length > 1 ? data.skip(1).toList() : [];
        } else {
          _headerRow = null;
          _dataRows = [];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _matchPositions = [];
      _currentMatchIndex = null;

      if (_searchQuery.isEmpty) {
        _matchCount = 0;
      } else {
        final rows = _dataRows ?? [];
        for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {
          final row = rows[rowIndex];
          for (int colIndex = 0; colIndex < row.length; colIndex++) {
            final cell = row[colIndex];
            if (cell.toString().toLowerCase().contains(_searchQuery)) {
              _matchPositions.add((row: rowIndex, col: colIndex));
            }
          }
        }
        _matchCount = _matchPositions.length;
        if (_matchPositions.isNotEmpty) {
          _currentMatchIndex = 0;
          _scrollToMatch();
        }
      }
    });
  }

  void _onPreviousMatch() {
    if (_matchPositions.isEmpty) return;
    setState(() {
      final index = (_currentMatchIndex ?? 0) - 1;
      _currentMatchIndex = index < 0 ? _matchPositions.length - 1 : index;
    });
    _scrollToMatch();
  }

  void _onNextMatch() {
    if (_matchPositions.isEmpty) return;
    setState(() {
      _currentMatchIndex =
          ((_currentMatchIndex ?? -1) + 1) % _matchPositions.length;
    });
    _scrollToMatch();
  }

  void _scrollToMatch() {
    final index = _currentMatchIndex;
    if (index == null || _matchPositions.isEmpty) return;

    final match = _matchPositions[index];
    const rowHeight = 48.0;
    const headerHeight = 56.0;
    const cellWidth = 150.0;

    final targetVerticalOffset = (match.row * rowHeight) + headerHeight - 100;
    final targetHorizontalOffset = (match.col * cellWidth).toDouble();

    if (_verticalScrollController.hasClients) {
      _verticalScrollController.animateTo(
        targetVerticalOffset.clamp(
          0.0,
          _verticalScrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    if (_horizontalScrollController.hasClients) {
      _horizontalScrollController.animateTo(
        targetHorizontalOffset.clamp(
          0.0,
          _horizontalScrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportToPdf,
            tooltip: 'PDF로 내보내기',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Future<void> _exportToPdf() async {
    if (_headerRow == null && (_dataRows == null || _dataRows!.isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('내보낼 데이터가 없습니다')));
      return;
    }

    await PdfExportUtils.showExportDialog(
      context: context,
      generatePdf: () => PdfExportUtils.convertCsvToPdf(
        headerRow: _headerRow,
        dataRows: _dataRows ?? [],
        title: widget.title,
      ),
      fileName: widget.title,
      onSuccess: () async {
        // PDF 저장 후 뷰어로 열기
        final pdfPath = await PdfExportUtils.savePdfToTemp(
          await PdfExportUtils.convertCsvToPdf(
            headerRow: _headerRow,
            dataRows: _dataRows ?? [],
            title: widget.title,
          ),
          widget.title,
        );

        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PdfViewerScreen(
                assetPath: pdfPath,
                title: '${widget.title} (PDF)',
                isAsset: false,
              ),
            ),
          );
        }
      },
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

    if (_headerRow == null && (_dataRows == null || _dataRows!.isEmpty)) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.table_chart_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '데이터가 없습니다',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(child: _buildTable()),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildTable() {
    final rows = _dataRows ?? [];
    final columnCount =
        _headerRow?.length ?? (rows.isNotEmpty ? rows.first.length : 0);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: ScrollbarTheme(
          data: const ScrollbarThemeData(mainAxisMargin: 0, crossAxisMargin: 0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                child: Scrollbar(
                  controller: _horizontalScrollController,
                  thumbVisibility: true,
                  scrollbarOrientation: ScrollbarOrientation.bottom,
                  notificationPredicate: (notification) =>
                      notification.metrics.axis == Axis.horizontal,
                  child: Scrollbar(
                    controller: _verticalScrollController,
                    thumbVisibility: true,
                    scrollbarOrientation: ScrollbarOrientation.right,
                    notificationPredicate: (notification) =>
                        notification.metrics.axis == Axis.vertical,
                    child: SingleChildScrollView(
                      controller: _verticalScrollController,
                      child: SingleChildScrollView(
                        controller: _horizontalScrollController,
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            Colors.grey.shade100,
                          ),
                          columns: _buildColumns(columnCount),
                          rows: _buildRows(rows),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns(int columnCount) {
    if (_headerRow != null) {
      return _headerRow!.map((cell) {
        return DataColumn(
          label: Text(
            cell.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        );
      }).toList();
    }

    return List.generate(columnCount, (index) {
      final letter = String.fromCharCode(65 + (index % 26));
      final prefix = index >= 26
          ? String.fromCharCode(65 + (index ~/ 26) - 1)
          : '';
      return DataColumn(
        label: Text(
          '$prefix$letter',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      );
    });
  }

  List<DataRow> _buildRows(List<List<dynamic>> rows) {
    return rows.asMap().entries.map((entry) {
      final rowIndex = entry.key;
      final row = entry.value;

      return DataRow(
        color: WidgetStateProperty.all(
          rowIndex.isEven ? Colors.white : Colors.grey.shade50,
        ),
        cells: row.asMap().entries.map((cellEntry) {
          final colIndex = cellEntry.key;
          final cell = cellEntry.value;
          final cellText = cell.toString();

          final isHighlighted =
              _searchQuery.isNotEmpty &&
              cellText.toLowerCase().contains(_searchQuery);

          final currentIndex = _currentMatchIndex;
          final isCurrentMatch =
              currentIndex != null &&
              _matchPositions.isNotEmpty &&
              _matchPositions[currentIndex].row == rowIndex &&
              _matchPositions[currentIndex].col == colIndex;

          return DataCell(
            Container(
              color: isCurrentMatch
                  ? Colors.orange.shade200
                  : (isHighlighted ? Colors.yellow.shade100 : null),
              child: Text(
                cellText,
                style: TextStyle(
                  color: isHighlighted
                      ? Colors.blue.shade700
                      : Colors.grey.shade700,
                  fontWeight: isHighlighted
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      );
    }).toList();
  }

  Widget _buildBottomBar() {
    final totalRows = (_dataRows?.length ?? 0) + (_headerRow != null ? 1 : 0);
    final totalCols =
        _headerRow?.length ??
        (_dataRows?.isNotEmpty == true ? _dataRows!.first.length : 0);

    return SearchBottomBar(
      showSearchInput: _showSearchInput,
      searchController: _searchController,
      searchFocusNode: _searchFocusNode,
      onSearchChanged: _onSearchChanged,
      onSearchToggle: () {
        setState(() {
          _showSearchInput = true;
        });
        _searchFocusNode.requestFocus();
      },
      onSearchClose: () {
        setState(() {
          _showSearchInput = false;
          _searchController.clear();
          _searchQuery = '';
          _matchCount = 0;
          _matchPositions = [];
          _currentMatchIndex = null;
        });
      },
      matchCount: _matchCount,
      currentMatchIndex: _currentMatchIndex,
      onPreviousMatch: _onPreviousMatch,
      onNextMatch: _onNextMatch,
      infoWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$totalRows행 × $totalCols열',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
