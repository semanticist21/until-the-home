# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**kkomi** is a Flutter application.

- **Package ID**: com.kobbokkom.kkomi
- **Flutter SDK**: ^3.11.0-93.1.beta

## Development Commands

```bash
# Get dependencies
flutter pub get

# Run app
flutter run

# Format code
dart format lib/

# Analyze code
dart analyze

# Run tests
flutter test

# Build release
flutter build apk --release   # Android
flutter build ios --release   # iOS
```

## Project Structure

```
lib/
└── main.dart          # App entry point
```

## Platform Configuration

- **Android**: `android/app/build.gradle.kts`
- **iOS**: `ios/Runner.xcodeproj/project.pbxproj`
