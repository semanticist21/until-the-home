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

## HWP 변환 API (Synology NAS)

Synology NAS에서 커스텀 HWP 변환 서버 운영 중.

### 엔드포인트

- **외부 URL**: `https://kkomjang.synology.me:4000/convert`
- **내부 URL**: `http://192.168.0.171:3131/convert`
- **메서드**: `POST` (multipart/form-data, field: `file`)

### 변환 파이프라인

```
HWP → ODT (pyhwp/hwp5odt) → PDF (LibreOffice headless)
```

- **pyhwp**: Python 라이브러리, `hwp5odt` 명령어로 HWP → ODT 변환
- **LibreOffice**: ODT → PDF 변환 (headless 모드)
- Gotenberg 기본 LibreOffice는 HWP 미지원 → 커스텀 Flask API 구현

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
