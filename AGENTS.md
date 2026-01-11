# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Kkomi** - Flutter document viewer/converter app supporting PDF, HWP, Office documents.

- **Package ID**: com.kobbokkom.kkomi
- **Dart SDK**: ^3.10.0
- **상태**: 출시 전 개발 중 (2026.01.11 기준)

## Development Commands

```bash
flutter pub get          # Get dependencies
flutter run              # Run app
dart format lib/         # Format code
dart analyze             # Analyze code
flutter test             # Run tests
flutter test test/widget_test.dart  # Run single test

# Build
flutter build apk --release   # Android
flutter build ios --release   # iOS
```

## Architecture

```text
lib/
├── core/
│   ├── theme/              # AppColors, AppTheme (Forui 테마)
│   ├── data/               # 데이터 레이어 (RecentDocumentsStore 등)
│   └── widgets/            # 재사용 공통 위젯 (App* 접두사)
│
├── screens/                # 화면별 모듈
│   └── [screen]/
│       ├── index.dart      # 메인 컴포넌트
│       ├── header.dart     # 헤더 (화면 전용)
│       └── body.dart       # 바디 (화면 전용)
│
└── main.dart
```

### Screen 구조 규칙

- 메인 컴포넌트: `index.dart`
- 화면 전용 컴포넌트: `header.dart`, `body.dart` 등 (재사용 안 하는 것)
- 재사용 컴포넌트만 `core/widgets/`에 배치
- 재사용 안 하는 컴포넌트는 inline 처리

### 지원 파일 포맷

- **뷰어 지원**: PDF, TXT, DOCX, CSV
- **뷰어 미지원 (라이브러리 없음)**: HWP, HWPX, DOC, XLS, XLSX, PPT, PPTX
- **파일 선택 지원**: PDF, HWP, HWPX, DOC, DOCX, XLS, XLSX, CSV, TXT

## Design System

### UI Framework: Forui

- **Forui** 사용 (shadcn/ui 스타일의 Flutter 컴포넌트 라이브러리)
- 공식 문서: <https://forui.dev>

### Theme

- `AppTheme.light` / `AppTheme.dark` - 커스텀 FThemeData
- `AppColors` - 색상 팔레트 (50-900 shades)

Color palette (warm brown/golden tones):

- **Primary**: `#B75634` - Warm brown (cat fur)
- **Secondary**: `#FDDC64` - Golden yellow (background)
- **Neutral**: Warm beige scale

### 공통 위젯

| Component         | 용도                          |
|-------------------|-------------------------------|
| `AppSectionTitle` | 섹션 제목                     |
| `AppProgress`     | 프로그레스 인디케이터         |
| `AppAdBanner`     | Google AdMob 배너             |

## Key Dependencies

- **forui**: UI 컴포넌트 프레임워크
- **pdfx**: PDF 뷰어
- **docx_file_viewer**: DOCX 뷰어 (네이티브 Flutter 렌더링)
- **csv**: CSV 파싱
- **file_picker**: 파일 선택
- **google_mobile_ads**: 광고
- **shared_preferences**: 로컬 저장소 (최근 문서 기록)

## Document Viewers

### PDF Viewer (`lib/screens/pdf_viewer/`)

- **패키지**: pdfx (PdfViewPinch)
- **기능**: 핀치 줌, 페이지 네비게이션
- **UI**: 하단바에 페이지 표시 (< 1/14 >)

### DOCX Viewer (`lib/screens/docx_viewer/`)

- **패키지**: docx_file_viewer v1.0.1
- **모드**: paged (페이지 단위 렌더링)
- **기능**: 핀치 줌, 텍스트 검색, 텍스트 선택
- **UI**: 하단바에 검색 버튼 (확장 시 검색 입력 + 네비게이션)
- **설정**: `DocxViewConfig` - padding, pageMode, showPageBreaks 등

### CSV Viewer (`lib/screens/csv_viewer/`)

- **패키지**: csv (CsvToListConverter)
- **기능**: 테이블 형태 표시, 검색, 행 필터링
- **UI**: DataTable, 하단바에 행×열 정보 + 검색 버튼

## Platform Configuration

- **Android**: `android/app/build.gradle.kts`
- **iOS**: `ios/Runner.xcodeproj/project.pbxproj`

## Document Conversion API (Synology NAS) - 제한적 사용

문서 변환 서버가 Synology NAS에서 Gotenberg Docker로 실행 중.

- **Base URL**: `https://kkomjang.synology.me:4000`
- **엔드포인트**: `/forms/libreoffice/convert`

### ⚠️ 한계점

- **NAS 기반**: 개인 NAS에서 구동되어 프로덕션 앱에서 사용 불가
- **실제 활용**: HWP → PDF 변환만 현실적으로 사용 가능
- **PPTX, XLSX 등**: 변환 가능하나 앱에서 활용하기엔 불안정

### 결론

- PPTX, XLSX 등은 Flutter에서 네이티브 뷰어 라이브러리 없음
- Gotenberg 의존 불가능 → 해당 포맷은 현재 뷰어 지원 어려움
- HWP만 Gotenberg로 PDF 변환 후 표시하는 방식 고려 가능
