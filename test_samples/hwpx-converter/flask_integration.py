#!/usr/bin/env python3
"""
HWPX Flask Integration
Add this to existing hwp_converter.py
"""

import os
import subprocess
import tempfile
from flask import Flask, request, send_file, jsonify
from werkzeug.utils import secure_filename

app = Flask(__name__)

# Existing HWP conversion route
@app.route('/convert', methods=['POST'])
def convert_hwp():
    """Convert HWP/HWPX files to PDF using hwp5odt + LibreOffice"""
    # ... existing HWP conversion code ...
    pass


# New HWPX conversion route using Java
@app.route('/convert_hwpx', methods=['POST'])
def convert_hwpx():
    """Convert HWPX files to PDF using Java hwpxlib"""
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400

    # Validate HWPX file
    if not file.filename.lower().endswith('.hwpx'):
        return jsonify({'error': 'Only HWPX files are supported'}), 400

    try:
        # Create temporary directory
        with tempfile.TemporaryDirectory() as work_dir:
            # Save uploaded HWPX file
            hwpx_filename = secure_filename(file.filename)
            hwpx_path = os.path.join(work_dir, hwpx_filename)
            file.save(hwpx_path)

            # Output PDF path
            pdf_filename = os.path.splitext(hwpx_filename)[0] + '.pdf'
            pdf_path = os.path.join(work_dir, pdf_filename)

            # Run Java converter
            jar_path = '/app/hwpx-converter-1.0.0.jar'  # Docker container path
            result = subprocess.run(
                ['java', '-jar', jar_path, hwpx_path, pdf_path],
                capture_output=True,
                text=True,
                timeout=180,
                env={'HOME': work_dir}
            )

            if result.returncode != 0:
                app.logger.error(f"Java conversion failed: {result.stderr}")
                return jsonify({
                    'error': 'HWPX conversion failed',
                    'details': result.stderr
                }), 500

            if not os.path.exists(pdf_path):
                return jsonify({'error': 'PDF file not generated'}), 500

            app.logger.info(f"Successfully converted {hwpx_filename} to PDF")

            # Send PDF file
            return send_file(
                pdf_path,
                mimetype='application/pdf',
                as_attachment=True,
                download_name=pdf_filename
            )

    except subprocess.TimeoutExpired:
        app.logger.error("HWPX conversion timeout")
        return jsonify({'error': 'Conversion timeout (>180s)'}), 504

    except Exception as e:
        app.logger.error(f"HWPX conversion error: {str(e)}")
        return jsonify({'error': str(e)}), 500


# Health check endpoint
@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'ok',
        'converters': ['hwp', 'hwpx']
    })


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
