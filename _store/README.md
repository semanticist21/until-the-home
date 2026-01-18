# Kkomi App Store Assets

Google Play Store 및 App Store 제출용 에셋 관리 디렉토리

## 📁 디렉토리 구조

```
_store/
├── google_play_1.png ~ 4.png      # Google Play 스크린샷 (1512x2688, 9:16)
├── play_store_listing.json        # Google Play 앱 정보 (제목, 설명)
├── fetch_ios_listing.py           # iOS 앱 정보 조회 스크립트
├── upload_to_play_store.py        # Google Play 업로드 스크립트
├── archive/                       # 보관 파일
│   ├── sources/                   # 소스 파일 (webp, svg)
│   ├── app_store/                 # App Store 전용 파일
│   ├── play_store_assets/         # Play Store 에셋
│   └── old_scripts/               # 레거시 스크립트
└── README.md                      # 이 파일
```

## 🚀 사용 방법

### 1. iOS 앱 정보 가져오기

```bash
python3 fetch_ios_listing.py
```

App Store Connect API에서 앱 제목, 설명을 조회하여 `play_store_listing.json`에 저장합니다.

**요구사항**:
- `~/Documents/API/AuthKey_74HC92L9NA.p8` (App Store Connect API 키)
- PyJWT, requests 패키지

### 2. Google Play에 업로드

```bash
python3 upload_to_play_store.py
```

Google Play Developer API를 사용하여:
- 앱 제목, 간단한 설명, 자세한 설명 업데이트
- 스크린샷 업로드 (google_play_*.png)

**요구사항**:
- `~/Documents/API/simple-anzan-3e199a55a5b1.json` (Google Service Account)
- google-api-python-client, google-auth 패키지

## 📱 스크린샷 사양

### Google Play
- **해상도**: 1512 x 2688 (9:16 비율)
- **포맷**: PNG
- **개수**: 4장 (최소 2장, 최대 8장)
- **크기**: 각 8MB 이하
- **용도**: 휴대전화 스크린샷

### App Store (참고)
- **해상도**: 1242 x 2688 (iPhone 6.7")
- **포맷**: PNG
- **개수**: iPad용 별도 필요 (ipad_*.png)

## 🔑 API 인증 정보

### App Store Connect API
- **Issuer ID**: `a7524762-b1db-463b-84a8-bbee51a37cc2`
- **Key ID**: `74HC92L9NA`
- **Private Key**: `~/Documents/API/AuthKey_74HC92L9NA.p8`

### Google Play Developer API
- **Package Name**: `com.kobbokkom.kkomi`
- **Service Account**: `simple-anzan@simple-anzan.iam.gserviceaccount.com`
- **JSON Key**: `~/Documents/API/simple-anzan-3e199a55a5b1.json`

## 📝 앱 정보

`play_store_listing.json`에서 관리:

```json
{
  "listings": {
    "ko-KR": {
      "title": "꼬미: 통합 문서 뷰어",
      "shortDescription": "PDF, HWP, 오피스 문서를...",
      "fullDescription": "다양한 포맷의 문서를..."
    }
  }
}
```

**제한**:
- 제목: 30자 (영문 기준)
- 간단한 설명: 80자
- 자세한 설명: 4000자

## 🗂️ Archive 파일

### sources/
원본 스크린샷 및 SVG 템플릿
- `1.webp ~ 4.webp`: 원본 스크린샷 (1179x2556)
- `preview_*.svg`: App Store용 템플릿 (1242x2688)
- `play_preview_*.svg`: Play Store용 템플릿 (1512x2688)

### app_store/
App Store 제출용 에셋
- `ipad_*.png`: iPad 스크린샷
- `app-icon.png`: 앱 아이콘

### play_store_assets/
Play Store 추가 에셋
- `play-store-app-icon-512.png`: 512x512 아이콘
- `play-store-feature-graphic.png`: 1024x500 기능 그래픽

## ⚙️ 의존성 설치

```bash
# App Store Connect API
pip3 install PyJWT requests

# Google Play Developer API
pip3 install google-api-python-client google-auth
```

## 📌 참고 사항

- Google Play API 업로드는 Edit 세션 방식 (한 번에 하나만 가능)
- 변경사항은 커밋 후 몇 시간 내에 반영됨
- iOS 앱 정보와 동기화하려면 `fetch_ios_listing.py` 먼저 실행
