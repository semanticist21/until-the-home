import 'dart:typed_data';

/// 문서를 PDF로 변환하는 추상 클래스
///
/// 각 파일 타입(TXT, CSV, HWP 등)은 이 클래스를 구현하여
/// PDF 변환 로직을 제공합니다.
abstract class DocumentConverter {
  /// 주어진 파일을 PDF 바이트로 변환
  ///
  /// [filePath]: 변환할 파일의 경로 (asset 또는 실제 파일 경로)
  /// [isAsset]: asset 경로 여부
  ///
  /// Returns: 변환된 PDF의 바이트 데이터
  /// Throws: 변환 실패 시 Exception
  Future<Uint8List> convertToPdf(String filePath, {bool isAsset = false});

  /// 변환기의 타입 (예: 'txt', 'csv', 'hwp')
  String get converterType;
}
