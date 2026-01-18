#!/usr/bin/env python3
"""
Google Play Developer API를 사용해서 앱 스토어 정보 업로드
- 앱 제목, 설명 업데이트
- 스크린샷 업로드
"""

import json
from pathlib import Path
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

# 설정
PACKAGE_NAME = "com.kobbokkom.kkomi"
SERVICE_ACCOUNT_FILE = Path.home() / "Documents/API/simple-anzan-3e199a55a5b1.json"
SCOPES = ['https://www.googleapis.com/auth/androidpublisher']

def get_service():
    """Google Play Developer API 서비스 생성"""
    credentials = service_account.Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE, scopes=SCOPES
    )
    service = build('androidpublisher', 'v3', credentials=credentials)
    return service

def upload_listing(service, edit_id, listing_data):
    """앱 정보 업데이트"""
    language = listing_data['defaultLanguage']
    info = listing_data['listings'][language]

    print(f"\n📝 앱 정보 업데이트 중...")
    print(f"  - 제목: {info['title']}")
    print(f"  - 간단한 설명: {info['shortDescription'][:50]}...")

    service.edits().listings().update(
        packageName=PACKAGE_NAME,
        editId=edit_id,
        language=language,
        body={
            'title': info['title'],
            'shortDescription': info['shortDescription'],
            'fullDescription': info['fullDescription']
        }
    ).execute()

    print("✅ 앱 정보 업데이트 완료")

def upload_screenshots(service, edit_id, language='ko-KR'):
    """스크린샷 업로드"""
    store_dir = Path(__file__).parent
    screenshots = list(store_dir.glob('google_play_*.png'))

    if not screenshots:
        print("⚠️  스크린샷을 찾을 수 없습니다.")
        return

    print(f"\n📸 스크린샷 업로드 중... ({len(screenshots)}장)")

    # 기존 스크린샷 삭제
    try:
        service.edits().images().deleteall(
            packageName=PACKAGE_NAME,
            editId=edit_id,
            language=language,
            imageType='phoneScreenshots'
        ).execute()
        print("  - 기존 스크린샷 삭제 완료")
    except Exception as e:
        print(f"  - 기존 스크린샷 없음 또는 삭제 실패: {e}")

    # 새 스크린샷 업로드
    for i, screenshot in enumerate(sorted(screenshots), 1):
        print(f"  - 업로드 중: {screenshot.name}")
        media = MediaFileUpload(str(screenshot), mimetype='image/png')
        service.edits().images().upload(
            packageName=PACKAGE_NAME,
            editId=edit_id,
            language=language,
            imageType='phoneScreenshots',
            media_body=media
        ).execute()

    print("✅ 스크린샷 업로드 완료")

def main():
    """메인 함수"""
    try:
        # 1. 서비스 생성
        print("🔑 Google Play Developer API 인증 중...")
        service = get_service()

        # 2. Edit 세션 생성
        print("📦 Edit 세션 생성 중...")
        edit = service.edits().insert(packageName=PACKAGE_NAME).execute()
        edit_id = edit['id']
        print(f"✅ Edit ID: {edit_id}")

        # 3. 앱 정보 로드
        listing_file = Path(__file__).parent / 'play_store_listing.json'
        with open(listing_file, 'r', encoding='utf-8') as f:
            listing_data = json.load(f)

        # 4. 앱 정보 업데이트
        upload_listing(service, edit_id, listing_data)

        # 5. 스크린샷 업로드
        upload_screenshots(service, edit_id)

        # 6. 변경사항 커밋
        print("\n💾 변경사항 커밋 중...")
        service.edits().commit(
            packageName=PACKAGE_NAME,
            editId=edit_id
        ).execute()

        print("\n" + "="*60)
        print("✅ Google Play Store 업데이트 완료!")
        print("변경사항이 몇 시간 내에 반영됩니다.")
        print("="*60)

    except Exception as e:
        print(f"\n❌ 오류 발생: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
