#!/usr/bin/env python3
"""
App Store Connect API를 사용해서 iOS 앱 정보 조회
조회한 정보를 play_store_listing.json에 반영
"""

import jwt
import time
import requests
import json
from pathlib import Path

# App Store Connect API 인증 정보
ISSUER_ID = "a7524762-b1db-463b-84a8-bbee51a37cc2"
KEY_ID = "74HC92L9NA"
PRIVATE_KEY_PATH = Path.home() / "Documents/API/AuthKey_74HC92L9NA.p8"

def generate_token():
    """JWT 토큰 생성"""
    with open(PRIVATE_KEY_PATH, 'r') as f:
        private_key = f.read()

    headers = {
        "alg": "ES256",
        "kid": KEY_ID,
        "typ": "JWT"
    }

    payload = {
        "iss": ISSUER_ID,
        "iat": int(time.time()),
        "exp": int(time.time()) + 20 * 60,  # 20분
        "aud": "appstoreconnect-v1"
    }

    token = jwt.encode(payload, private_key, algorithm="ES256", headers=headers)
    return token

def fetch_app_info():
    """앱 정보 조회"""
    token = generate_token()
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }

    # 1. 앱 목록 조회
    response = requests.get(
        "https://api.appstoreconnect.apple.com/v1/apps",
        headers=headers
    )
    response.raise_for_status()
    apps = response.json()

    if not apps['data']:
        print("앱을 찾을 수 없습니다.")
        return None

    # 첫 번째 앱 선택 (Kkomi 앱)
    app = apps['data'][0]
    app_id = app['id']
    bundle_id = app['attributes']['bundleId']

    print(f"앱 ID: {app_id}")
    print(f"Bundle ID: {bundle_id}")

    # 2. 앱 정보 (App Info) 조회
    response = requests.get(
        f"https://api.appstoreconnect.apple.com/v1/apps/{app_id}/appInfos",
        headers=headers
    )
    response.raise_for_status()
    app_infos = response.json()

    if not app_infos['data']:
        print("앱 정보를 찾을 수 없습니다.")
        return None

    app_info_id = app_infos['data'][0]['id']

    # 3. 앱 정보 로컬라이제이션 조회
    response = requests.get(
        f"https://api.appstoreconnect.apple.com/v1/appInfos/{app_info_id}/appInfoLocalizations",
        headers=headers
    )
    response.raise_for_status()
    localizations = response.json()

    # 한국어 로컬라이제이션 찾기
    ko_localization = None
    for loc in localizations['data']:
        if loc['attributes']['locale'] == 'ko':
            ko_localization = loc
            break

    if not ko_localization:
        print("한국어 로컬라이제이션을 찾을 수 없습니다.")
        return None

    name = ko_localization['attributes'].get('name', '')
    subtitle = ko_localization['attributes'].get('subtitle', '')

    print(f"\n앱 이름: {name}")
    print(f"부제목: {subtitle}")

    # 4. 앱 스토어 버전 조회 (설명 가져오기) - 모든 상태 포함
    response = requests.get(
        f"https://api.appstoreconnect.apple.com/v1/apps/{app_id}/appStoreVersions",
        headers=headers
    )
    response.raise_for_status()
    versions = response.json()

    if not versions['data']:
        print("버전을 찾을 수 없습니다. 앱 정보만 사용합니다.")
        return {
            "title": name or subtitle,
            "shortDescription": subtitle or "",
            "fullDescription": ""
        }

    version_id = versions['data'][0]['id']
    version_state = versions['data'][0]['attributes'].get('appStoreState', 'UNKNOWN')
    print(f"버전 상태: {version_state}")

    # 5. 버전 로컬라이제이션 조회
    response = requests.get(
        f"https://api.appstoreconnect.apple.com/v1/appStoreVersions/{version_id}/appStoreVersionLocalizations",
        headers=headers
    )
    response.raise_for_status()
    version_localizations = response.json()

    # 한국어 버전 로컬라이제이션 찾기
    ko_version_loc = None
    for loc in version_localizations['data']:
        if loc['attributes']['locale'] == 'ko':
            ko_version_loc = loc
            break

    if not ko_version_loc:
        print("한국어 버전 로컬라이제이션을 찾을 수 없습니다.")
        return None

    description = ko_version_loc['attributes'].get('description', '')
    promotional_text = ko_version_loc['attributes'].get('promotionalText', '')

    print(f"홍보 텍스트: {promotional_text[:100] if promotional_text else '(없음)'}")
    print(f"설명: {description[:100]}...")

    return {
        "title": name or subtitle,  # 이름이 없으면 부제목 사용
        "shortDescription": promotional_text or subtitle,  # 홍보 텍스트 또는 부제목
        "fullDescription": description
    }

def update_play_store_listing(ios_info):
    """play_store_listing.json 업데이트"""
    listing_file = Path(__file__).parent / "play_store_listing.json"

    with open(listing_file, 'r', encoding='utf-8') as f:
        listing = json.load(f)

    listing['listings']['ko-KR'].update(ios_info)

    with open(listing_file, 'w', encoding='utf-8') as f:
        json.dump(listing, f, ensure_ascii=False, indent=2)

    print(f"\n✅ {listing_file} 업데이트 완료")

if __name__ == "__main__":
    try:
        ios_info = fetch_app_info()
        if ios_info:
            print("\n" + "="*60)
            print("조회된 정보:")
            print(json.dumps(ios_info, ensure_ascii=False, indent=2))
            print("="*60)

            update_play_store_listing(ios_info)
    except Exception as e:
        print(f"❌ 오류: {e}")
        import traceback
        traceback.print_exc()
