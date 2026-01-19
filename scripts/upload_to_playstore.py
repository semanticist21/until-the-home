#!/usr/bin/env python3
"""
Upload AAB to Google Play Store using Google Play Developer API v3
"""

import sys
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

# Configuration
SERVICE_ACCOUNT_FILE = '/Users/semanticist/Documents/API/simple-anzan-3e199a55a5b1.json'
PACKAGE_NAME = 'com.kobbokkom.kkomi'
AAB_FILE = 'build/app/outputs/bundle/release/app-release.aab'
TRACK = 'production'  # production, beta, alpha, internal

def upload_to_playstore():
    """Upload AAB and submit to production track"""

    print("🔐 Authenticating with Google Play API...")
    credentials = service_account.Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE,
        scopes=['https://www.googleapis.com/auth/androidpublisher']
    )

    service = build('androidpublisher', 'v3', credentials=credentials)

    try:
        # Create a new edit session
        print("📝 Creating new edit session...")
        edit_request = service.edits().insert(body={}, packageName=PACKAGE_NAME)
        edit = edit_request.execute()
        edit_id = edit['id']
        print(f"✅ Edit ID: {edit_id}")

        # Upload the AAB
        print(f"📦 Uploading AAB: {AAB_FILE}")
        media = MediaFileUpload(AAB_FILE, mimetype='application/octet-stream', resumable=True)
        upload_request = service.edits().bundles().upload(
            editId=edit_id,
            packageName=PACKAGE_NAME,
            media_body=media
        )
        bundle_response = upload_request.execute()
        version_code = bundle_response['versionCode']
        print(f"✅ Uploaded version code: {version_code}")

        # Assign to production track
        print(f"🚀 Assigning to {TRACK} track...")
        track_request = service.edits().tracks().update(
            editId=edit_id,
            track=TRACK,
            packageName=PACKAGE_NAME,
            body={
                'releases': [{
                    'versionCodes': [version_code],
                    'status': 'completed',  # completed = submit for review
                }]
            }
        )
        track_response = track_request.execute()
        print(f"✅ Track updated: {track_response['track']}")

        # Commit the changes
        print("💾 Committing changes...")
        commit_request = service.edits().commit(
            editId=edit_id,
            packageName=PACKAGE_NAME
        )
        commit_response = commit_request.execute()
        print(f"✅ Committed edit ID: {commit_response['id']}")

        print("\n🎉 Successfully submitted to Google Play Store!")
        print(f"Version code {version_code} is now submitted for review.")

    except Exception as e:
        print(f"\n❌ Error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    upload_to_playstore()
