import 'package:flutter/material.dart';

/// 문서 타입별 색상 정의
///
/// 각 문서 포맷에 대한 브랜드 색상을 제공합니다.
/// 최근 문서 목록, 파일 타입 배지 등에서 일관된 색상을 사용하기 위해
/// 중앙 집중식으로 관리합니다.
class DocumentColors {
  DocumentColors._();

  /// 문서 타입에 따른 색상 반환
  ///
  /// [type]: 문서 타입 (PDF, HWP, DOCX 등)
  /// Returns: 해당 문서 타입에 맞는 브랜드 색상
  static Color getTypeColor(String type) {
    switch (type) {
      case 'PDF':
        return const Color(0xFFE53935); // Red - Adobe PDF
      case 'HWP':
      case 'HWPX':
        return const Color(0xFF1E88E5); // Blue - Hancom
      case 'DOC':
      case 'DOCX':
        return const Color(0xFF2E7D32); // Green - Microsoft Word
      case 'XLS':
      case 'XLSX':
        return const Color(0xFF1D6F42); // Dark Green - Microsoft Excel
      case 'PPT':
      case 'PPTX':
        return const Color(0xFFD84315); // Orange - Microsoft PowerPoint
      case 'TXT':
        return const Color(0xFF546E7A); // Blue Grey - Plain Text
      case 'CSV':
        return const Color(0xFF7B1FA2); // Purple - CSV Data
      default:
        return Colors.grey; // Default for unsupported types
    }
  }
}
