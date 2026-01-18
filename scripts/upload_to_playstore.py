#!/usr/bin/env python3
"""
Google Play Store App Bundle Upload Script
Uses Google Play Developer API to upload AAB files
"""

import sys
import os
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

# Configuration
SERVICE_ACCOUNT_FILE = '/Users/semanticist/Documents/API/simple-anzan-3e199a55a5b1.json'
PACKAGE_NAME = 'com.kobbokkom.kkomi'
AAB_FILE = 'build/app/outputs/bundle/release/app-release.aab'
TRACK = 'production'  # production, beta, alpha, internal

def upload_to_playstore():
    """Upload App Bundle to Google Play Store"""

    # Check if AAB file exists
    if not os.path.exists(AAB_FILE):
        print(f"❌ Error: AAB file not found at {AAB_FILE}")
        sys.exit(1)

    print(f"📦 Uploading {AAB_FILE} to Google Play Store...")
    print(f"   Package: {PACKAGE_NAME}")
    print(f"   Track: {TRACK}")

    # Authenticate
    credentials = service_account.Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE,
        scopes=['https://www.googleapis.com/auth/androidpublisher']
    )

    service = build('androidpublisher', 'v3', credentials=credentials)

    try:
        # Step 1: Create an edit
        print("\n1️⃣ Creating edit...")
        edit_request = service.edits().insert(packageName=PACKAGE_NAME)
        edit = edit_request.execute()
        edit_id = edit['id']
        print(f"   ✅ Edit ID: {edit_id}")

        # Step 2: Upload the bundle
        print("\n2️⃣ Uploading bundle...")
        bundle_request = service.edits().bundles().upload(
            packageName=PACKAGE_NAME,
            editId=edit_id,
            media_body=MediaFileUpload(AAB_FILE, mimetype='application/octet-stream')
        )
        bundle_response = bundle_request.execute()
        version_code = bundle_response['versionCode']
        print(f"   ✅ Bundle uploaded. Version code: {version_code}")

        # Step 3: Assign to track
        print(f"\n3️⃣ Assigning to {TRACK} track...")
        track_request = service.edits().tracks().update(
            packageName=PACKAGE_NAME,
            editId=edit_id,
            track=TRACK,
            body={
                'releases': [{
                    'versionCodes': [version_code],
                    'status': 'completed',  # completed = go live immediately
                }]
            }
        )
        track_response = track_request.execute()
        print(f"   ✅ Assigned to {TRACK} track")

        # Step 4: Commit the edit
        print("\n4️⃣ Committing edit...")
        commit_request = service.edits().commit(
            packageName=PACKAGE_NAME,
            editId=edit_id
        )
        commit_response = commit_request.execute()
        print(f"   ✅ Edit committed successfully!")

        print("\n✅ Upload completed successfully!")
        print(f"   Version code {version_code} is now in {TRACK} track")

    except Exception as e:
        print(f"\n❌ Upload failed: {e}")
        sys.exit(1)

if __name__ == '__main__':
    upload_to_playstore()
