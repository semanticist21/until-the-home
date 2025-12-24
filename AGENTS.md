# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Kkomi** - Flutter application for document conversion (PDF, HWP).

- **Package ID**: com.kobbokkom.kkomi
- **Flutter SDK**: ^3.11.0-93.1.beta

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

Feature-First Clean Architecture:

```
lib/
├── core/                    # Shared utilities
│   ├── constants/          # App-wide constants
│   ├── network/            # API client, interceptors
│   ├── theme/              # Colors, typography, themes
│   ├── utils/              # Helper functions
│   └── widgets/            # Reusable widgets
│
├── features/               # Feature modules
│   └── [feature]/
│       ├── data/           # Repository impl, data sources
│       ├── domain/         # Entities, use cases, repo interfaces
│       └── presentation/   # UI, state management (BLoC/Provider)
│
└── main.dart
```

## Design System

### UI Framework: Forui

- **Forui** 사용 (shadcn/ui 스타일의 Flutter 컴포넌트 라이브러리)
- 공식 문서: https://forui.dev

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
  variant: AppButtonVariant.primary,  // primary, secondary, outline, ghost, destructive
  icon: Icons.save,
  isLoading: false,
  isFullWidth: false,
  onPressed: () {},
)
```

| App Component | Forui Widget | 위치 |
|---------------|--------------|------|
| `AppButton` | `FButton` | `lib/core/widgets/app_button.dart` |

새 공통 컴포넌트 추가 시 동일 패턴 따를 것.

## Platform Configuration

- **Android**: `android/app/build.gradle.kts`
- **iOS**: `ios/Runner.xcodeproj/project.pbxproj`
