import 'package:flutter/material.dart';

/// 검색 하단바 공통 위젯 (DOCX, CSV 등에서 사용)
class SearchBottomBar extends StatelessWidget {
  const SearchBottomBar({
    super.key,
    required this.showSearchInput,
    required this.searchController,
    required this.searchFocusNode,
    required this.onSearchChanged,
    required this.onSearchToggle,
    required this.onSearchClose,
    this.matchCount = 0,
    this.currentMatchIndex,
    this.onPreviousMatch,
    this.onNextMatch,
    this.infoWidget,
  });

  final bool showSearchInput;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchToggle;
  final VoidCallback onSearchClose;
  final int matchCount;
  final int? currentMatchIndex;
  final VoidCallback? onPreviousMatch;
  final VoidCallback? onNextMatch;
  final Widget? infoWidget;

  @override
  Widget build(BuildContext context) {
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
        child: showSearchInput ? _buildSearchInput() : _buildInfoBar(),
      ),
    );
  }

  Widget _buildInfoBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (infoWidget != null) infoWidget!,
        if (infoWidget != null) const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: onSearchToggle,
          color: Colors.grey.shade700,
        ),
      ],
    );
  }

  Widget _buildSearchInput() {
    final hasNavigation = onPreviousMatch != null && onNextMatch != null;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            focusNode: searchFocusNode,
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
            onChanged: onSearchChanged,
          ),
        ),
        const SizedBox(width: 8),
        if (matchCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              hasNavigation && currentMatchIndex != null
                  ? '${currentMatchIndex! + 1} / $matchCount'
                  : '$matchCount건',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        if (hasNavigation) ...[
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up, size: 20),
            onPressed: matchCount > 0 ? onPreviousMatch : null,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            color: Colors.grey.shade700,
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            onPressed: matchCount > 0 ? onNextMatch : null,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            color: Colors.grey.shade700,
          ),
        ],
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: onSearchClose,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          color: Colors.grey.shade700,
        ),
      ],
    );
  }
}
