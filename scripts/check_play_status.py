#!/usr/bin/env python3
"""
Google Play Console 앱 상태 확인 스크립트
"""

import json
import sys
from pathlib import Path

from google.oauth2 import service_account
from googleapiclient.discovery import build

# 설정
SERVICE_ACCOUNT_FILE = '/Users/semanticist/Documents/API/simple-anzan-3e199a55a5b1.json'
PACKAGE_NAME = 'com.kobbokkom.kkomi'
SCOPES = ['https://www.googleapis.com/auth/androidpublisher']


def get_service():
    """Google Play Developer API 서비스 객체 생성"""
    credentials = service_account.Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE, scopes=SCOPES
    )
    return build('androidpublisher', 'v3', credentials=credentials)


def check_tracks(service):
    """모든 트랙의 릴리스 상태 확인"""
    print("=" * 60)
    print("📦 릴리스 트랙 상태")
    print("=" * 60)

    tracks = ['internal', 'alpha', 'beta', 'production']

    for track_name in tracks:
        try:
            track = service.edits().tracks().get(
                packageName=PACKAGE_NAME,
                editId=edit_id,
                track=track_name
            ).execute()

            print(f"\n🎯 {track_name.upper()} 트랙:")

            if 'releases' in track and track['releases']:
                for release in track['releases']:
                    version_codes = release.get('versionCodes', [])
                    status = release.get('status', 'unknown')
                    user_fraction = release.get('userFraction', 1.0)

                    print(f"  - 버전: {version_codes}")
                    print(f"  - 상태: {status}")
                    if user_fraction < 1.0:
                        print(f"  - 롤아웃: {user_fraction * 100}%")

                    if 'releaseNotes' in release:
                        for note in release['releaseNotes']:
                            lang = note.get('language', 'unknown')
                            text = note.get('text', '')
                            if text:
                                print(f"  - 릴리스 노트 ({lang}): {text[:100]}...")
            else:
                print(f"  ℹ️  릴리스 없음")

        except Exception as e:
            print(f"  ❌ 오류: {str(e)}")


def check_app_details(service):
    """앱 기본 정보 확인"""
    print("\n" + "=" * 60)
    print("📱 앱 기본 정보")
    print("=" * 60)

    try:
        # 앱 세부정보 가져오기
        details = service.edits().details().get(
            packageName=PACKAGE_NAME,
            editId=edit_id
        ).execute()

        print(f"\n연락처 이메일: {details.get('contactEmail', 'N/A')}")
        print(f"연락처 전화: {details.get('contactPhone', 'N/A')}")
        print(f"연락처 웹사이트: {details.get('contactWebsite', 'N/A')}")
        print(f"기본 언어: {details.get('defaultLanguage', 'N/A')}")

    except Exception as e:
        print(f"❌ 앱 정보 조회 오류: {str(e)}")


def check_listings(service):
    """앱 리스팅 정보 확인"""
    print("\n" + "=" * 60)
    print("🌐 앱 리스팅 (언어별)")
    print("=" * 60)

    try:
        listings = service.edits().listings().list(
            packageName=PACKAGE_NAME,
            editId=edit_id
        ).execute()

        for listing in listings.get('listings', []):
            lang = listing.get('language', 'unknown')
            title = listing.get('title', 'N/A')
            short_desc = listing.get('shortDescription', 'N/A')

            print(f"\n🌍 {lang}:")
            print(f"  제목: {title}")
            print(f"  짧은 설명: {short_desc[:100]}...")

    except Exception as e:
        print(f"❌ 리스팅 조회 오류: {str(e)}")


def check_in_app_products(service):
    """인앱 상품 상태 확인"""
    print("\n" + "=" * 60)
    print("💰 인앱 상품")
    print("=" * 60)

    try:
        products = service.inappproducts().list(
            packageName=PACKAGE_NAME
        ).execute()

        if 'inappproduct' in products and products['inappproduct']:
            for product in products['inappproduct']:
                sku = product.get('sku', 'unknown')
                status = product.get('status', 'unknown')
                price = product.get('prices', {})

                print(f"\n🛍️  SKU: {sku}")
                print(f"  상태: {status}")
                if price:
                    for currency, amount in list(price.items())[:3]:
                        print(f"  가격 ({currency}): {amount.get('priceMicros', 0) / 1000000}")
        else:
            print("\nℹ️  등록된 인앱 상품 없음")

    except Exception as e:
        print(f"❌ 인앱 상품 조회 오류: {str(e)}")


def main():
    """메인 실행 함수"""
    global edit_id

    print("\n🔍 Google Play Console 앱 상태 확인")
    print(f"📦 패키지: {PACKAGE_NAME}\n")

    try:
        service = get_service()

        # Edit 세션 시작
        edit_request = service.edits().insert(
            packageName=PACKAGE_NAME,
            body={}
        ).execute()
        edit_id = edit_request['id']

        # 모든 정보 확인
        check_tracks(service)
        check_app_details(service)
        check_listings(service)
        check_in_app_products(service)

        # Edit 세션 삭제 (변경사항 없으므로)
        service.edits().delete(
            packageName=PACKAGE_NAME,
            editId=edit_id
        ).execute()

        print("\n" + "=" * 60)
        print("✅ 조회 완료")
        print("=" * 60 + "\n")

    except Exception as e:
        print(f"\n❌ 오류 발생: {str(e)}")
        sys.exit(1)


if __name__ == '__main__':
    main()
