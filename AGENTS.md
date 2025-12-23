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

Color palette extracted from app icon (warm brown/golden tones):

- **Primary**: `#B75634` - Warm brown (cat fur)
- **Secondary**: `#FDDC64` - Golden yellow (background)
- **Neutral**: Warm beige scale

Colors defined in `lib/core/theme/app_colors.dart` with 50-900 shades.

## Platform Configuration

- **Android**: `android/app/build.gradle.kts`
- **iOS**: `ios/Runner.xcodeproj/project.pbxproj`
