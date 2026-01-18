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
flutter test test/viewers/pdf_viewer_test.dart  # Run specific test

# Production Build
# 1. Remove PDFium WASM modules (4MB reduction, Web-only)
dart run pdfrx:remove_wasm_modules

# 2. Build release
flutter build apk --release   # Android
flutter build ios --release   # iOS

# 3. Restore WASM for development
dart run pdfrx:remove_wasm_modules --revert
```

## Google Play Store Deployment

### App Bundle Build

```bash
# 1. Remove WASM modules (production optimization)
dart run pdfrx:remove_wasm_modules

# 2. Build release AAB
flutter build appbundle --release

# 3. Output location
# build/app/outputs/bundle/release/app-release.aab

# 4. Restore WASM for development
dart run pdfrx:remove_wasm_modules --revert
```

### Signing Configuration

- **Keystore**: `android/upload-keystore.jks` (excluded from git)
- **Credentials**: `android/key.properties` (excluded from git)
- **Build Config**: `android/app/build.gradle.kts` (signingConfigs.release)

### Version Management

앱 버전 업데이트 시 `pubspec.yaml`의 `version` 필드 수정:

```yaml
version: 1.0.0+6  # 형식: major.minor.patch+buildNumber
```

- **Android**: `buildNumber` → `versionCode`
- **iOS**: `major.minor.patch` → `CFBundleShortVersionString`, `buildNumber` → `CFBundleVersion`
- **앱 스토어 심사 제출 시 버전 증가 필수**

### Permission Policy Compliance

앱은 photo/video 권한을 명시적으로 제거하여 Play Store 정책을 준수:

```xml
<!-- AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />

    <!-- Explicitly remove photo/video permissions - app only handles documents -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" tools:node="remove" />
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" tools:node="remove" />
```

**배경**: `file_picker` 패키지가 Android 13+에서 자동으로 추가하는 photo/video 권한을 제거. Kkomi는 문서 파일만 처리하므로 불필요.

## Logging

Use `appLogger` from `lib/core/utils/app_logger.dart` for all logging:

```dart
import '../../core/utils/app_logger.dart';

appLogger.d('[COMPONENT] Debug message');    // Debug
appLogger.i('[COMPONENT] Info message');     // Info
appLogger.w('[COMPONENT] Warning message');  // Warning
appLogger.e('[COMPONENT] Error', error: e, stackTrace: st);  // Error
```

- **Auto-disabled in release**: Logs only appear in debug builds
- **Never use print()**: Use appLogger instead
- **Prefix convention**: `[COMPONENT]` for easy log filtering

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

### Document Handler Pattern

파일 열기는 통합 핸들러 사용 (`lib/screens/home/recent_documents_handlers.dart`):

```dart
// 단일 switch 문으로 통합된 핸들러
bool openRecentDocument(BuildContext context, RecentDocument doc) {
  final isAsset = _isAssetPath(doc.path);

  switch (doc.type) {
    case 'PDF':
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => UniversalPdfViewer(...)),
      );
      return true;
    case 'TXT':
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => UniversalPdfViewer(converter: TxtToPdfConverter())),
      );
      return true;
    // ... other cases
    default:
      return false;
  }
}
```

지원 포맷:
- PDF, TXT, CSV (네이티브 PDF 뷰어)
- HWP, HWPX, DOC, XLS, PPT, PPTX (NAS 변환 후 PDF 뷰어)
- DOCX, XLSX (DOCX 뷰어, XML 포맷만 지원)

### UniversalPdfViewer - Unified Document Viewing

**패턴**: `lib/screens/universal_pdf_viewer/index.dart`

통합 PDF 뷰어로 모든 문서 타입을 처리하는 중앙 컴포넌트:

```dart
// 직접 PDF 로드
UniversalPdfViewer(
  filePath: '/path/to/file.pdf',
  title: 'Document',
  isAsset: false,
)

// 변환기를 사용한 로드 (TXT, CSV, HWP 등)
UniversalPdfViewer(
  filePath: '/path/to/file.txt',
  title: 'Document',
  converter: TxtToPdfConverter(),  // DocumentConverter 구현체
)
```

**동작 방식**:
1. `converter`가 null → 직접 PDF 로드 (`CommonPdfViewer` 사용)
2. `converter` 제공 → 파일 변환 → 임시 저장 → PDF 뷰어 표시
3. 변환 중 에러 → 상태코드별 사용자 친화적 메시지 표시 (400: 손상/암호, 413: 크기 초과, 500: 서버 오류)

### DocumentConverter Pattern

**추상 클래스**: `lib/core/converters/document_converter.dart`

모든 문서 변환기는 `DocumentConverter` 인터페이스를 구현:

```dart
abstract class DocumentConverter {
  Future<Uint8List> convertToPdf(String filePath, {bool isAsset = false});
  String get converterType;
}
```

**구현체**:
- `TxtToPdfConverter`: TXT → PDF (다국어 폰트 지원)
- `CsvToPdfConverter`: CSV → PDF (테이블 형식)
- `NasToPdfConverter`: HWP/Office → PDF (NAS API 사용)

**사용 패턴**:
```dart
final converter = TxtToPdfConverter();
final pdfBytes = await converter.convertToPdf(filePath);
// pdfBytes를 CommonPdfViewer 또는 UniversalPdfViewer로 전달
```

#### 플랫폼별 네이티브 뷰어 지원 (2026.01.17)

"외부 뷰어로 열기" 설정 시 플랫폼별 처리:

```dart
// iOS: iWork(Pages/Numbers/Keynote) 내장 → DOCX/XLSX/PPTX 지원
// Android: Office 앱 설치 여부 불확실 → 항상 앱 내부 뷰어 사용
// 레거시 포맷(HWP/HWPX/DOC/XLS/PPT)은 모든 플랫폼에서 제외
final nativeViewerFormats = Platform.isIOS
    ? ['DOCX', 'XLSX', 'PPTX']
    : <String>[];
```

**동작 방식**:
- **iOS + 외부 뷰어 ON**: DOCX/XLSX/PPTX → Pages/Numbers/Keynote, 나머지 → 앱 내부 뷰어
- **Android + 외부 뷰어 ON**: 모든 포맷 → 앱 내부 뷰어 (Office 앱 설치 불확실)
- **외부 뷰어 OFF**: 모든 플랫폼/포맷 → 앱 내부 뷰어

### 지원 파일 포맷

- **네이티브 뷰어 지원**: PDF, TXT, CSV
- **DOCX 뷰어 지원**: DOCX, XLSX (XML 포맷만)
- **변환 후 뷰어 지원**: HWP, HWPX, DOC, XLS, PPT, PPTX (NAS API → PDF 변환)
- **파일 선택 지원**: PDF, HWP, HWPX, DOC, DOCX, XLS, XLSX, PPT, PPTX, CSV, TXT

### 파일 크기 제한

**Gotenberg 변환 포맷만 제한** (2026.01.17 추가):
- **제한 포맷**: HWP, HWPX, DOC, XLS, PPT, PPTX
- **제한 크기**: 25MB
- **네이티브 뷰어**: 제한 없음 (PDF, TXT, CSV, DOCX, XLSX)
- **변환 시간**: 25MB 기준 약 13-15초
- **초과 시 동작**: 다이얼로그로 안내 후 파일 열기 취소

## 파일 확장자 연결 (File Association)

**패키지**: `receive_sharing_intent: ^1.8.1`

사용자가 다른 앱(파일 탐색기, 이메일 등)에서 문서를 열 때 Kkomi를 선택할 수 있는 기능.

### Android 구현

`AndroidManifest.xml`에 intent-filter 설정:
- **ACTION_VIEW**: 파일을 직접 열기 (파일 탐색기)
- **ACTION_SEND**: 다른 앱에서 공유하기

지원 MIME Types:
- `application/pdf`, `application/vnd.hancom.hwp`, `application/vnd.hancom.hwpx`
- `application/vnd.openxmlformats-officedocument.*` (DOCX, XLSX, PPTX)
- `text/plain`, `text/csv`

### Flutter 처리 로직 (`main.dart`)

```dart
// 1. 앱 실행 중 공유 받기
ReceiveSharingIntent.instance.getMediaStream().listen((files) {
  _handleSharedFile(files.first);
});

// 2. 앱 닫힌 상태에서 실행 시 공유 받기
ReceiveSharingIntent.instance.getInitialMedia().then((files) {
  _handleSharedFile(files.first);
  ReceiveSharingIntent.instance.reset();
});

// 3. 파일 처리
void _handleSharedFile(SharedMediaFile file) {
  // - RecentDocumentsStore에 추가
  // - openRecentDocument()로 뷰어 열기
}
```

### iOS (향후 구현 필요)

Share Extension 생성 필요:
- `Info.plist` 설정 (CFBundleDocumentTypes, UTI)
- Share Extension Swift 코드
- App Group 설정

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

**위젯 네이밍 규칙**:
- 재사용 가능한 공통 위젯은 `App*` 접두사 사용
- 화면 전용 위젯은 접두사 없이 `screens/[screen]/` 내부에 배치

| Component          | 용도                                     |
|--------------------|------------------------------------------|
| `AppSectionTitle`  | 섹션 제목 (trailing 파라미터로 우측 위젯 추가 가능) |
| `AppProgress`      | 프로그레스 인디케이터                    |
| `AppAdBanner`      | Google AdMob 배너                        |
| `AppLoading`       | 전체 화면 로딩 (AppProgress 래퍼)       |
| `SearchBottomBar`  | 검색 기능이 있는 하단 바 (재사용 가능)  |
| `CommonPdfViewer`  | 통합 PDF 뷰어 (PDF/TXT/CSV 공통 사용)   |

#### SearchBottomBar 사용법

```dart
SearchBottomBar(
  showSearchInput: _showSearchInput,
  searchController: _searchController,
  searchFocusNode: _searchFocusNode,
  matchCount: _matchCount,
  currentMatchIndex: _currentMatchIndex,
  onSearchToggle: () { /* 검색 입력 표시/숨김 */ },
  onSearchClose: () { /* 검색 닫기 */ },
  onSearchChanged: (query) { /* 검색 쿼리 변경 */ },
  onPreviousMatch: () { /* 이전 매치 */ },
  onNextMatch: () { /* 다음 매치 */ },
  infoWidget: Row(  // 선택적: 커스텀 정보 위젯
    children: [/* 페이지 네비게이션 등 */],
  ),
)
```

## State Management

- **RecentDocumentsStore** (`lib/core/data/recent_documents_store.dart`):
  - Singleton pattern으로 구현
  - `shared_preferences`를 사용한 로컬 영속성
  - 최근 열람 문서 기록 저장/로드
  - 메서드: `addDocument()`, `getDocuments()`, `removeDocument()`

- **UsageStreakStore** (`lib/core/data/usage_streak_store.dart`):
  - Singleton pattern으로 구현
  - 앱 연속 사용일 추적 (날짜 기반)
  - 로직: 첫 실행 = 1일, 하루 차이 = +1일, 2일 이상 차이 = 리셋
  - 메서드: `updateStreak()` (main.dart에서 앱 시작 시 호출)
  - ValueNotifier: `currentStreak` (홈 화면에서 실시간 표시)

- **WeeklyLimitStore** (`lib/core/data/weekly_limit_store.dart`):
  - Singleton pattern으로 구현
  - 주간 사용량 한도 관리 (월요일 기준 리셋)
  - 기본 한도: 200
  - 메서드: `checkWeeklyReset()`, `addUsage(amount)`, `setWeeklyLimit(newLimit)`
  - ValueNotifier: `currentUsage`, `weeklyLimit`
  - Getters: `remainingUsage`, `usageRatio`, `daysUntilReset`
  - ⚠️ TODO: main.dart에서 `checkWeeklyReset()` 호출 필요, 문서 열람 시 `addUsage()` 호출 필요

## Key Dependencies

- **forui**: UI 컴포넌트 프레임워크
- **pdfrx**: PDF 뷰어 (v2.2.24, PdfTextSearcher 지연 초기화 필요)
- **pdf**: PDF 생성 (CSV/TXT → PDF 변환)
- **docx_file_viewer**: DOCX 뷰어 (네이티브 Flutter 렌더링, local package)
- **csv**: CSV 파싱
- **data_table_2**: 고급 DataTable (CSV 뷰어용)
- **file_picker**: 파일 선택 대화상자
- **receive_sharing_intent**: 파일 확장자 연결 (다른 앱에서 파일 열기)
- **open_filex**: 네이티브 외부 뷰어로 파일 열기 (iOS iWork 등)
- **google_mobile_ads**: 광고 (iOS/Android만 지원)
- **shared_preferences**: 로컬 저장소 (최근 문서, 설정, 사용량 등)
- **logger**: Debug-only 로깅 (appLogger)
- **path_provider**: 임시 디렉토리 및 앱 디렉토리 경로

## Document Viewers

### Common PDF Viewer (`lib/core/widgets/common_pdf_viewer.dart`)

**공통 PDF 뷰어 컴포넌트** - PDF, TXT, CSV 뷰어가 모두 사용하는 통합 뷰어

- **패키지**: pdfrx v2.2.24
- **입력 타입**: 3가지 지원 (하나만 제공)
  - `pdfBytes`: Uint8List (TXT/CSV 변환 후 사용)
  - `assetPath`: Asset 파일 경로
  - `filePath`: 실제 파일 경로
- **기능**: 핀치 줌, 페이지 네비게이션, 텍스트 검색
- **UI**: SearchBottomBar (검색 + 페이지 네비게이션)
- **콜백**: `onSave` (선택적, PDF 저장 버튼 표시)

**사용 예시**:
```dart
// PDF 파일 직접 로드
CommonPdfViewer(filePath: '/path/to/file.pdf')

// Asset PDF 로드
CommonPdfViewer(assetPath: 'assets/sample.pdf')

// 변환된 PDF 바이트 로드 (TXT/CSV)
CommonPdfViewer(
  pdfBytes: convertedBytes,
  onSave: () async {
    // PDF 저장 로직
  },
)
```

#### 검색 기능 (Search)

- **Lazy Initialization**: PdfTextSearcher를 첫 검색 시에만 생성
  ```dart
  // ❌ Wrong: 초기화 시 생성 (pdfrx v2.2.13+ 버그)
  _textSearcher = PdfTextSearcher(_controller!);

  // ✅ Right: 첫 검색 시 생성
  if (_textSearcher == null && _controller != null) {
    _textSearcher = PdfTextSearcher(_controller!)
      ..addListener(_updateSearchResults);
  }
  ```

- **Transparent Highlights**: 하이라이트된 텍스트가 가려지지 않도록 투명도 사용
  ```dart
  matchTextColor: Colors.yellow.withValues(alpha: 0.3),        // 일반 매치
  activeMatchTextColor: Colors.orange.withValues(alpha: 0.5),  // 활성 매치
  ```

- **Paint Callbacks**: 검색 결과 하이라이트 렌더링
  ```dart
  pagePaintCallbacks: [
    if (_textSearcher != null)
      _textSearcher!.pageTextMatchPaintCallback,
  ],
  ```

### PDF Viewer (`lib/screens/pdf_viewer/`)

- **구조**: PDF 파일 로드 → CommonPdfViewer 사용
- **입력**: Asset 또는 파일 경로
- **UI**: SearchBottomBar (검색 + 페이지 네비게이션)

### DOCX Viewer (`lib/screens/docx_viewer/`)

- **패키지**: docx_file_viewer v1.0.1
- **모드**: paged (페이지 단위 렌더링)
- **기능**: 핀치 줌, 텍스트 검색, 텍스트 선택
- **UI**: 하단바에 검색 버튼 (확장 시 검색 입력 + 네비게이션)
- **설정**: `DocxViewConfig` - padding, pageMode, showPageBreaks 등

### CSV Viewer (`lib/screens/csv_viewer/`)

- **구조**: CSV 파일 파싱 → PDF 변환 → CommonPdfViewer 사용
- **패키지**: csv (파싱), pdf (생성)
- **변환 설정**: A4 가로(landscape), 테이블 형식, 헤더 강조
- **기능**: 검색, PDF 저장
- **PDF 저장**: AppBar 우측에 PDF 아이콘 버튼

### TXT Viewer (`lib/screens/txt_viewer/`)

- **구조**: TXT 파일 읽기 → PDF 변환 → CommonPdfViewer 사용
- **패키지**: pdf (생성)
- **변환 설정**: A4 세로, 페이지당 약 50줄, 다국어 폰트 fallback 체인
- **다국어 폰트**: Korean, Japanese, Chinese, Thai, Arabic, Hebrew, Hindi, Russian, Greek, Georgian, Armenian, Bengali, Tamil, Vietnamese, Math symbols
- **⚠️ 폰트 한계**: Polish(ą,ć,ę,ł,ń,ś,ź,ż), Turkish(ş,ğ,İ) 미지원 (Noto Sans Latin Extended 추가 필요)
- **기능**: 검색, PDF 저장
- **PDF 저장**: AppBar 우측에 PDF 아이콘 버튼

## Platform Configuration

- **Android**: `android/app/build.gradle.kts`
- **iOS**: `ios/Runner.xcodeproj/project.pbxproj`

## HWP 변환 API (Synology NAS)

Synology NAS에서 커스텀 HWP 변환 서버 운영 중.

### 엔드포인트

**통합 Docker 컨테이너** (2026.01.17 업데이트):

| 포트 | 서비스 | 용도 | URL |
|------|--------|------|-----|
| **4000** | nginx + Gotenberg + Flask | HWP/Office → PDF | `https://kkomjang.synology.me:4000` |

**내부 구조**:
```
외부 HTTPS → Synology nginx (4000)
           ↓ (SSL 종료)
           localhost:4001 (HTTP)
           ↓
           Docker 컨테이너 (gotenberg-hwp-all)
           ├── nginx (4000) - Basic Auth, 리버스 프록시
           ├── Gotenberg (3000) - Office 문서 변환
           └── Flask (3131) - HWP 변환
```

**엔드포인트**:
- **HWP 변환**: `https://kkomjang.synology.me:4000/convert`
- **Office 변환**: `https://kkomjang.synology.me:4000/forms/libreoffice/convert`

- **메서드**: `POST` (multipart/form-data)
- **필드명**: `file` (Flask/HWP), `files` (Gotenberg/Office)
- **지원 포맷**: HWP/HWPX (Flask), DOC/DOCX/XLS/XLSX/PPT/PPTX (Gotenberg)
- **인증**: Basic Authentication (Username: `kkomi`, Password: `kkomi`)
  - 2026.01.17 추가: nginx에서 `auth_basic` 설정
  - Flutter 앱: `Authorization: Basic a2tvbWk6a2tvbWk=` 헤더 자동 포함
  - curl 예시: `curl -u kkomi:kkomi -X POST -F "file=@doc.hwp" https://kkomjang.synology.me:4000/convert`

### 변환 파이프라인

**HWP 변환 (2단계)**:
```
HWP/HWPX → ODT (pyhwp/hwp5odt) → PDF (LibreOffice headless)
```
- **pyhwp**: Python 라이브러리, `hwp5odt` 명령어로 HWP → ODT 변환
- **LibreOffice**: ODT → PDF 변환 (headless 모드)
- Gotenberg 기본 LibreOffice는 HWP 미지원 → 커스텀 Flask API 구현

**Office 변환 (1단계)**:
```
DOC/DOCX/XLS/XLSX/PPT/PPTX → PDF (LibreOffice headless, Gotenberg)
```
- **Gotenberg**: LibreOffice가 Office 포맷(구형/신형 모두)을 네이티브 지원
- **변환 속도**: HWP보다 2배 이상 빠름 (중간 단계 없음)
- **레거시 포맷**: DOC, XLS, PPT (바이너리 포맷)도 변환 가능

### Docker 구성

- **컨테이너**: `gotenberg-hwp-all`
- **이미지**: `gotenberg-hwp-all:latest`
- **포트 매핑**: `4001:4000` (호스트:컨테이너)
- **위치**: `/volume1/docker/gotenberg-hwp-nginx/`
- **서비스 관리**: supervisord (nginx, Gotenberg, Flask)

### 배포 방법

**파일 전송** (base64 방식 - SSH 권한 문제 우회):

```bash
# 파일을 base64로 인코딩하여 SSH로 전송
ENCODED=$(base64 -i /tmp/gotenberg-hwp-nginx/FILE | tr -d '\n')

expect << EOF
spawn ssh semanticist@192.168.0.171
expect "password:"
send "wldnjsqkr14!\r"
expect "$ "
send "echo '$ENCODED' | base64 -d > /volume1/docker/gotenberg-hwp-nginx/FILE\r"
expect "$ "
send "exit\r"
expect eof
EOF
```

**컨테이너 재빌드**:

```bash
# NAS SSH 접속
ssh semanticist@192.168.0.171

# 빌드 및 재시작
cd /volume1/docker/gotenberg-hwp-nginx
sudo docker build -t gotenberg-hwp-all .
sudo docker stop gotenberg-hwp-all
sudo docker rm gotenberg-hwp-all
sudo docker run -d --name gotenberg-hwp-all -p 4001:4000 --restart unless-stopped gotenberg-hwp-all

# 상태 확인
sudo docker ps | grep gotenberg
# 출력: Up X minutes (정상), Restarting (문제 있음)
```

### LibreOffice Writer 타임아웃 해결 (2026.01.17)

**문제**: DOC 파일 변환 시 LibreOffice Writer 초기화에 20초+ 소요 → 기본 타임아웃 20초 초과

**원인**: LibreOffice 컴포넌트별 초기화 시간 차이
- Writer (DOC/DOCX): 20+ 초
- Calc (XLS/XLSX): 2-3 초
- Impress (PPT/PPTX): 2-3 초

**해결**: `services.conf`에서 Gotenberg 시작 옵션 변경

```ini
[program:gotenberg]
command=/usr/bin/tini -- gotenberg \
  --api-timeout=300s \
  --libreoffice-start-timeout=60s  # 20초 → 60초
```

**테스트 결과**:

| 포맷 | 원본 크기 | 변환 시간 | PDF 크기 | 상태 |
|------|-----------|-----------|----------|------|
| HWP | 40KB | 6.5초 | 60KB | ✅ |
| DOC | 25KB | 2.8초 | 42KB | ✅ 수정 후 성공 |
| XLS | 16KB | 2.2초 | 72KB | ✅ |
| XLSX | 29KB | 0.67초 | 35KB | ✅ |
| PPT | 891KB | 1.5초 | 286KB | ✅ |
| PPTX | 46MB | 21-28초 | 14MB | ✅ |

### 컨테이너 관리

**상태 확인**:

```bash
sudo docker ps | grep gotenberg
# 출력 예시:
# - Up X minutes: 정상 작동
# - Restarting: 문제 발생 (로그 확인 필요)
```

**로그 확인**:

```bash
# 전체 로그
sudo docker logs gotenberg-hwp-all

# 실시간 로그
sudo docker logs -f gotenberg-hwp-all

# 특정 서비스 로그
sudo docker logs gotenberg-hwp-all | grep gunicorn
sudo docker logs gotenberg-hwp-all | grep gotenberg
```

**변환 테스트**:

```bash
# HWP 변환
curl -u kkomi:kkomi -X POST \
  -F "file=@sample.hwp" \
  https://kkomjang.synology.me:4000/convert \
  -o output.pdf

# Office 변환 (타임아웃 65초)
curl -u kkomi:kkomi -X POST \
  -F "files=@large.pptx" \
  https://kkomjang.synology.me:4000/forms/libreoffice/convert \
  -o output.pdf --max-time 65
```

### ⚠️ 시행착오 및 해결책 (2026.01.16)

| 문제 | 원인 | 해결책 |
|------|------|--------|
| LibreOffice 120초 타임아웃 | 동시 요청 시 사용자 프로필 락 충돌 | 요청마다 고유 프로필 디렉토리 생성 |
| gunicorn 로그 미출력 | supervisord stdout 설정 누락 | `stdout_logfile=/dev/fd/1` 추가 |
| HOME 환경변수 미설정 | Flask에서 subprocess 호출 시 HOME 없음 | `env["HOME"] = work_dir` 설정 |

### 핵심 코드 (hwp_converter.py)

```python
# 각 요청마다 고유 LibreOffice 프로필 생성 (락 충돌 방지)
lo_profile = os.path.join(work_dir, "lo_profile")
os.makedirs(lo_profile, exist_ok=True)

env = os.environ.copy()
env["HOME"] = work_dir  # HOME 환경변수 필수

subprocess.run([
    "libreoffice", "--headless",
    "--nofirststartwizard", "--norestore",
    f"-env:UserInstallation=file://{lo_profile}",  # 고유 프로필 경로
    "--convert-to", "pdf",
    "--outdir", work_dir,
    odt_path
], env=env, timeout=180)
```

### Worker 설정 및 병렬 처리

**Gunicorn Worker 설정** (`services.conf`):

```ini
[program:hwpconverter]
command=gunicorn -b 0.0.0.0:3131 -w 4 --timeout 300 --log-level debug hwp_converter:app
```

- **Worker 개수**: `-w 4` (동시 처리 가능 요청 수)
- **권장**: CPU 코어수에 맞춰 설정 (DS224+ = 4코어 → 4 workers)

**병렬 처리 성능**:

| Worker 수 | 4개 동시 요청 처리 시간 | 동시 처리 패턴 |
|-----------|-------------------------|---------------|
| 2개 | 9.87초 | 2개씩 배치 처리 (5초 + 10초) |
| 4개 | 6.00초 | 4개 동시 처리 (~6초) |

**⚠️ Worker 설정 변경 시 주의사항**:

로컬에서 `services.conf` 수정 후 반드시 **컨테이너 안으로 복사** 필요:

```bash
# 1. 컨테이너에 파일 복사
sudo docker cp /tmp/services.conf gotenberg-hwp-all:/etc/supervisor/conf.d/services.conf

# 2. 컨테이너 재시작
sudo docker restart gotenberg-hwp-all

# 3. 설정 확인
sudo docker exec gotenberg-hwp-all ps aux | grep gunicorn
# Master 1개 + Worker N개 = 총 N+1개 프로세스 확인
```

### Nginx 설정 (Basic Auth)

**주요 파일**:
- **nginx.conf**: `/etc/nginx/nginx.conf` (컨테이너 내부)
- **htpasswd**: `/etc/nginx/.htpasswd` (kkomi:kkomi)

**설정 예시**:

```nginx
http {
    upstream gotenberg {
        server localhost:3000;
    }
    upstream flask {
        server localhost:3131;
    }

    server {
        listen 4000;
        auth_basic "Restricted Access";
        auth_basic_user_file /etc/nginx/.htpasswd;

        location /convert {
            proxy_pass http://flask;
        }
        location /forms/libreoffice/convert {
            proxy_pass http://gotenberg;
        }
        location /health {
            auth_basic off;
            return 200 "OK";
        }
    }
}
```

### NAS SSH 접속

```bash
ssh semanticist@192.168.0.171
# password: wldnjsqkr14!
# docker 명령어는 sudo 필요
```

### 한계점

- **NAS 기반**: 개인 NAS에서 구동 → 프로덕션 앱에서 안정성 보장 어려움
- **네트워크 의존**: 외부 네트워크 상태에 따라 504 Gateway Timeout 발생 가능
- **변환 의존**: HWP, Office 레거시 포맷(DOC/XLS/PPT)은 Flutter 네이티브 뷰어 없음 → NAS 변환 필수
- **보안 한계** (Basic Authentication):
  - 단일 계정 (`kkomi:kkomi`) → 사용자별 구분 불가
  - 인증 정보를 아는 사람은 누구나 curl/Postman으로 호출 가능
  - 우연한 접근/크롤러는 차단되지만, 의도적 접근은 가능
  - 더 강화하려면: API 키 방식, IP 화이트리스트, Rate Limiting 고려

## Testing

### Test Structure

```text
test/
├── viewers/              # 뷰어별 테스트
│   ├── pdf_viewer_test.dart
│   ├── csv_viewer_test.dart
│   └── txt_viewer_test.dart
└── conversions/          # 변환 관련 테스트
```

### Test Patterns

#### Widget Tests

```dart
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Component Name Tests', () {
    testWidgets('should show expected UI', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: YourWidget()),
      );
      await tester.pump();

      expect(find.text('Expected Text'), findsOneWidget);
    });
  });
}
```

#### Skipping Tests with Timers

PDF 뷰어처럼 비동기 로딩이 지속적인 타이머를 생성하는 경우:

```dart
testWidgets('complex async test', (tester) async {
  // ... test code
}, skip: true);  // Skip: PDF loading creates persistent timers
```

### Running Tests

```bash
# 전체 테스트
flutter test

# 특정 파일
flutter test test/viewers/pdf_viewer_test.dart

# 특정 그룹
flutter test --name "PDF Viewer Widget Tests"
```

## Test Samples

### HWPX Converter (Java/Maven)

**위치**: `tools/hwpx-converter/`

HWPX 파일을 PDF로 변환하는 Java 애플리케이션. 현재는 사용하지 않음 (NAS에서 통합 변환 처리).

#### 폰트 파일 설정

**필수 폰트**:
- `AppleSDGothicNeo.ttc` (52.81MB) - macOS 시스템 폰트
- `NotoSansKR.ttf` - Google Noto Sans 한글 폰트

**설치 위치**: `src/main/resources/`

**다운로드 방법**:

1. **AppleSDGothicNeo.ttc** (macOS 전용):
   ```bash
   # macOS 시스템 폰트 복사
   cp /System/Library/Fonts/Supplemental/AppleSDGothicNeo.ttc \
      tools/hwpx-converter/src/main/resources/
   ```

2. **NotoSansKR.ttf**:
   - 다운로드: https://fonts.google.com/noto/specimen/Noto+Sans+KR
   - 또는 `tools/hwpx-converter/src/main/resources/` 폴더에 직접 배치

**⚠️ 주의**: 폰트 파일은 `.gitignore`에 등록되어 있으므로 git에 커밋되지 않습니다. 각 개발 환경에서 개별적으로 다운로드 필요.

#### 빌드 방법

```bash
cd tools/hwpx-converter
mvn clean package

# JAR 파일 생성: target/hwpx-converter-1.0.0.jar
```

#### 로컬 테스트

```bash
./test_local.sh sample.hwpx
# 출력: sample.pdf
```
