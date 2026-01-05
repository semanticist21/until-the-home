#!/usr/bin/env python3
"""
HWP to PDF Conversion API Server
Simple Flask server for document conversion using LibreOffice + H2Orestart
"""

import os
import subprocess
import tempfile
import uuid
from flask import Flask, request, send_file, jsonify
from werkzeug.utils import secure_filename

app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = 50 * 1024 * 1024  # 50MB max

ALLOWED_EXTENSIONS = {'hwp', 'hwpx', 'doc', 'docx', 'rtf', 'odt', 'txt', 'html'}
WORK_DIR = '/data/work'

os.makedirs(WORK_DIR, exist_ok=True)


def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'ok'})


@app.route('/convert', methods=['POST'])
def convert():
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400

    if not allowed_file(file.filename):
        return jsonify({'error': f'File type not allowed. Allowed: {ALLOWED_EXTENSIONS}'}), 400

    # Create unique work directory
    job_id = str(uuid.uuid4())
    job_dir = os.path.join(WORK_DIR, job_id)
    os.makedirs(job_dir, exist_ok=True)

    try:
        # Save uploaded file
        filename = secure_filename(file.filename)
        input_path = os.path.join(job_dir, filename)
        file.save(input_path)

        # Convert to PDF
        result = subprocess.run(
            ['soffice', '--headless', '--convert-to', 'pdf', input_path, '--outdir', job_dir],
            capture_output=True,
            text=True,
            timeout=120
        )

        if result.returncode != 0:
            return jsonify({
                'error': 'Conversion failed',
                'details': result.stderr
            }), 500

        # Find output PDF
        pdf_name = os.path.splitext(filename)[0] + '.pdf'
        pdf_path = os.path.join(job_dir, pdf_name)

        if not os.path.exists(pdf_path):
            return jsonify({'error': 'PDF not generated'}), 500

        # Return PDF file
        return send_file(
            pdf_path,
            mimetype='application/pdf',
            as_attachment=True,
            download_name=pdf_name
        )

    except subprocess.TimeoutExpired:
        return jsonify({'error': 'Conversion timeout'}), 504
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        # Cleanup (keep for debugging in dev, remove in prod)
        import shutil
        shutil.rmtree(job_dir, ignore_errors=True)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000)
