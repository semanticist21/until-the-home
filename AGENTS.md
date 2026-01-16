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
- HWP, HWPX, PPTX (NAS 변환 후 PDF 뷰어)
- DOCX, DOC, XLS, XLSX (DOCX 뷰어)

### 지원 파일 포맷

- **네이티브 뷰어 지원**: PDF, TXT, DOCX, CSV
- **변환 후 뷰어 지원**: HWP, HWPX, PPTX (NAS API → PDF 변환)
- **뷰어 미지원**: DOC, XLS, XLSX, PPT
- **파일 선택 지원**: PDF, HWP, HWPX, DOC, DOCX, XLS, XLSX, PPTX, CSV, TXT

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
- **data_table_2**: 고급 DataTable (CSV 뷰어)
- **file_picker**: 파일 선택
- **google_mobile_ads**: 광고 (iOS/Android만 지원)
- **shared_preferences**: 로컬 저장소 (최근 문서 기록)
- **logger**: Debug-only 로깅 (appLogger)

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

### Version Management

앱 버전 업데이트 시 `pubspec.yaml`의 `version` 필드 수정:

```yaml
version: 1.0.0+1  # 형식: major.minor.patch+buildNumber
```

- **Android**: `buildNumber` → `versionCode`
- **iOS**: `major.minor.patch` → `CFBundleShortVersionString`, `buildNumber` → `CFBundleVersion`
- **앱 스토어 심사 제출 시 버전 증가 필수**

## HWP 변환 API (Synology NAS)

Synology NAS에서 커스텀 HWP 변환 서버 운영 중.

### 엔드포인트

| 포트 | 서비스 | 용도 | URL |
|------|--------|------|-----|
| **4000** | Flask (HWP 변환) | HWP → PDF | `https://kkomjang.synology.me:4000/convert` |
| **4001** | Gotenberg (Office 변환) | PPTX/DOCX/XLSX → PDF | `https://kkomjang.synology.me:4001/forms/libreoffice/convert` |
| **3131** | Flask (내부) | HWP 변환 (내부) | `http://192.168.0.171:3131/convert` |
| **3000** | Gotenberg (내부) | Office 변환 (내부) | `http://192.168.0.171:3000/forms/libreoffice/convert` |

- **메서드**: `POST` (multipart/form-data)
- **필드명**: `file` (Flask), `files` (Gotenberg)

### 변환 파이프라인

**HWP 변환 (2단계)**:
```
HWP → ODT (pyhwp/hwp5odt) → PDF (LibreOffice headless)
```
- **pyhwp**: Python 라이브러리, `hwp5odt` 명령어로 HWP → ODT 변환
- **LibreOffice**: ODT → PDF 변환 (headless 모드)
- Gotenberg 기본 LibreOffice는 HWP 미지원 → 커스텀 Flask API 구현

**PPTX/Office 변환 (1단계)**:
```
PPTX/DOCX/XLSX → PDF (LibreOffice headless, Gotenberg)
```
- **Gotenberg**: LibreOffice가 Office 포맷을 네이티브 지원
- **변환 속도**: HWP보다 2배 이상 빠름 (중간 단계 없음)

### Docker 구성

- **컨테이너**: `gotenberg-hwp-gotenberg-1`
- **이미지**: `gotenberg-hwp-gotenberg:latest` (Gotenberg + pyhwp + Flask)
- **포트**: 3131 (Flask API), 3000 (Gotenberg 원본)
- **위치**: `/volume1/docker/gotenberg-hwp/`

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
command=gunicorn -b 0.0.0.0:5000 -w 4 --timeout 300 --log-level debug hwp_converter:app
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
sudo docker cp /tmp/services.conf gotenberg-hwp-gotenberg-1:/etc/supervisor/conf.d/services.conf

# 2. 컨테이너 재시작
sudo docker restart gotenberg-hwp-gotenberg-1

# 3. 설정 확인
sudo docker exec gotenberg-hwp-gotenberg-1 ps aux | grep gunicorn
# Master 1개 + Worker N개 = 총 N+1개 프로세스 확인
```

**테스트 방법**:

```bash
# 4개 동시 요청 테스트
for i in {1..4}; do
  curl -X POST -F "file=@sample.hwp" \
    https://kkomjang.synology.me:4000/convert \
    -o test_${i}.pdf &
done
wait
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
- **HWP 전용**: PPTX, XLSX 등은 Flutter 네이티브 뷰어 라이브러리 없음

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
