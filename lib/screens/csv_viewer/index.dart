import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/search_bottom_bar.dart';

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
      if (_searchQuery.isEmpty) {
        _matchCount = 0;
      } else {
        int count = 0;
        for (final row in _dataRows ?? []) {
          for (final cell in row) {
            if (cell.toString().toLowerCase().contains(_searchQuery)) {
              count++;
            }
          }
        }
        _matchCount = count;
      }
    });
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
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('CSV 로딩 중...'),
          ],
        ),
      );
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
          data: const ScrollbarThemeData(
            mainAxisMargin: 0,
            crossAxisMargin: 0,
          ),
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
      final prefix =
          index >= 26 ? String.fromCharCode(65 + (index ~/ 26) - 1) : '';
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
        cells: row.map((cell) {
          final cellText = cell.toString();
          final isHighlighted = _searchQuery.isNotEmpty &&
              cellText.toLowerCase().contains(_searchQuery);

          return DataCell(
            Container(
              color: isHighlighted ? Colors.yellow.shade100 : null,
              child: Text(
                cellText,
                style: TextStyle(
                  color: isHighlighted
                      ? Colors.blue.shade700
                      : Colors.grey.shade700,
                  fontWeight:
                      isHighlighted ? FontWeight.w600 : FontWeight.normal,
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
        });
      },
      matchCount: _matchCount,
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
