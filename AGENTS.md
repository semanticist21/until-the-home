# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Kkomi** - Flutter application for document conversion (PDF, HWP).

- **Package ID**: com.kobbokkom.kkomi
- **Flutter SDK**: ^3.10.0

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
├── core/                    # 공통 유틸리티
│   ├── theme/              # AppColors, AppTheme
│   └── widgets/            # 재사용 가능한 공통 위젯 (App* 접두사)
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

### Component Wrapping Pattern

Forui 위젯을 `App*` 접두사로 래핑하여 공통 컴포넌트화:

```dart
// 사용 예시
AppButton(
  label: 'Save',
  variant: AppButtonVariant.primary,
  onPressed: () {},
)
```

| App Component     | Forui Widget | 위치                                      |
|-------------------|--------------|-------------------------------------------|
| `AppButton`       | `FButton`    | `lib/core/widgets/app_button.dart`        |
| `AppSectionTitle` | -            | `lib/core/widgets/app_section_title.dart` |

## Platform Configuration

- **Android**: `android/app/build.gradle.kts`
- **iOS**: `ios/Runner.xcodeproj/project.pbxproj`

## Document Conversion API (Synology NAS)

문서 변환 서버가 Synology NAS에서 Gotenberg Docker로 실행 중.

### Gotenberg API (외부 접속용 - DDNS)

- **Base URL**: `https://kkomjang.synology.me:4000`
- **엔드포인트**: `/forms/libreoffice/convert`
- **지원 포맷**: HWP, HWPX, DOC, DOCX, XLS, XLSX, PPT, PPTX, RTF, ODT, TXT 등 → PDF

```bash
# Health check
curl https://kkomjang.synology.me:4000/health

# 문서 → PDF 변환
curl -X POST "https://kkomjang.synology.me:4000/forms/libreoffice/convert" \
  -F "files=@document.hwp" \
  -o output.pdf

# 여러 파일 병합
curl -X POST "https://kkomjang.synology.me:4000/forms/libreoffice/convert" \
  -F "files=@doc1.docx" \
  -F "files=@doc2.xlsx" \
  -o merged.pdf
```

### 내부 네트워크 (로컬 개발용)

- **Gotenberg**: `http://192.168.0.171:4000`
- **hwp.js API**: `http://192.168.0.171:3002` (텍스트 추출용)

### Docker 파일 위치

- `docker/hwp-js-converter/` - hwp.js (HWP→HTML/Text)
