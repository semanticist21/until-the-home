#!/usr/bin/env python3
"""
Google Play Developer API로 등록된 모든 앱 조회
"""

from pathlib import Path
from google.oauth2 import service_account
from googleapiclient.discovery import build

SERVICE_ACCOUNT_FILE = Path.home() / "Documents/API/simple-anzan-3e199a55a5b1.json"
SCOPES = ['https://www.googleapis.com/auth/androidpublisher']

def main():
    print("🔑 Google Play Developer API 인증 중...")
    credentials = service_account.Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE, scopes=SCOPES
    )
    service = build('androidpublisher', 'v3', credentials=credentials)

    # applicationsList는 없고, 직접 packageName으로 접근만 가능
    # 대신 여러 패키지 이름으로 시도해보기
    test_packages = [
        "com.kobbokkom.kkomi",
        "com.example.app",
        "simple.anzan",  # 프로젝트 ID 기반 추측
    ]

    print("\n📱 등록된 앱 조회 중...\n")

    for package in test_packages:
        try:
            # Edit 세션 생성 시도 (앱이 존재하면 성공)
            edit = service.edits().insert(packageName=package).execute()
            print(f"✅ {package}")
            print(f"   Edit ID: {edit['id']}")

            # Edit 세션 삭제
            service.edits().delete(packageName=package, editId=edit['id']).execute()
        except Exception as e:
            if "404" in str(e):
                print(f"❌ {package} - 앱 없음")
            else:
                print(f"⚠️  {package} - 오류: {e}")

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"\n❌ 오류: {e}")
        import traceback
        traceback.print_exc()
