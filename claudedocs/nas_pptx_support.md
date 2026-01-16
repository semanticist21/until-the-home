# NAS API - PPTX 지원 추가

## 개요

기존 `hwp_converter.py`를 확장해서 PPTX → PDF 변환을 지원합니다.

## 수정된 코드 (hwp_converter.py)

```python
import os
import subprocess
import tempfile
from pathlib import Path

from flask import Flask, request, send_file

app = Flask(__name__)


@app.route('/convert', methods=['POST'])
def convert():
    """HWP, HWPX, PPTX 파일을 PDF로 변환"""
    if 'file' not in request.files:
        return 'No file uploaded', 400

    file = request.files['file']
    if not file.filename:
        return 'No filename', 400

    # 파일 확장자 확인
    ext = Path(file.filename).suffix.lower()

    if ext in ['.hwp', '.hwpx']:
        return _convert_hwp(file)
    elif ext in ['.pptx', '.ppt']:
        return _convert_pptx(file)
    else:
        return f'Unsupported file type: {ext}', 400


def _convert_hwp(file):
    """HWP → ODT → PDF 변환 (기존 로직)"""
    work_dir = tempfile.mkdtemp()

    try:
        # HWP 파일 저장
        hwp_path = os.path.join(work_dir, "input.hwp")
        file.save(hwp_path)

        # 1단계: HWP → ODT (pyhwp 사용)
        odt_path = os.path.join(work_dir, "output.odt")
        subprocess.run(
            ["hwp5odt", hwp_path, "-o", odt_path],
            check=True,
            timeout=60,
            capture_output=True,
        )

        # 2단계: ODT → PDF (LibreOffice)
        lo_profile = os.path.join(work_dir, "lo_profile")
        os.makedirs(lo_profile, exist_ok=True)

        env = os.environ.copy()
        env["HOME"] = work_dir

        subprocess.run([
            "libreoffice", "--headless",
            "--nofirststartwizard", "--norestore",
            f"-env:UserInstallation=file://{lo_profile}",
            "--convert-to", "pdf",
            "--outdir", work_dir,
            odt_path
        ], env=env, check=True, timeout=180)

        pdf_path = os.path.join(work_dir, "output.pdf")
        if not os.path.exists(pdf_path):
            return 'PDF conversion failed', 500

        return send_file(pdf_path, mimetype='application/pdf')

    except subprocess.TimeoutExpired:
        return 'Conversion timeout', 504
    except subprocess.CalledProcessError as e:
        return f'Conversion error: {e.stderr.decode()}', 500
    except Exception as e:
        return f'Unexpected error: {str(e)}', 500


def _convert_pptx(file):
    """PPTX → PDF 직접 변환 (LibreOffice 네이티브 지원)"""
    work_dir = tempfile.mkdtemp()

    try:
        # PPTX 파일 저장
        pptx_path = os.path.join(work_dir, "input.pptx")
        file.save(pptx_path)

        # LibreOffice로 직접 PDF 변환
        lo_profile = os.path.join(work_dir, "lo_profile")
        os.makedirs(lo_profile, exist_ok=True)

        env = os.environ.copy()
        env["HOME"] = work_dir

        subprocess.run([
            "libreoffice", "--headless",
            "--nofirststartwizard", "--norestore",
            f"-env:UserInstallation=file://{lo_profile}",
            "--convert-to", "pdf",
            "--outdir", work_dir,
            pptx_path
        ], env=env, check=True, timeout=180)

        pdf_path = os.path.join(work_dir, "input.pdf")
        if not os.path.exists(pdf_path):
            return 'PDF conversion failed', 500

        return send_file(pdf_path, mimetype='application/pdf')

    except subprocess.TimeoutExpired:
        return 'Conversion timeout', 504
    except subprocess.CalledProcessError as e:
        return f'Conversion error: {e.stderr.decode()}', 500
    except Exception as e:
        return f'Unexpected error: {str(e)}', 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

## 적용 방법

### 1. NAS에 SSH 접속

```bash
ssh semanticist@192.168.0.171
# password: wldnjsqkr14!
```

### 2. 기존 파일 백업

```bash
sudo docker cp gotenberg-hwp-gotenberg-1:/app/hwp_converter.py \
  /volume1/docker/gotenberg-hwp/hwp_converter.py.bak
```

### 3. 로컬에서 수정된 파일 복사

```bash
# 로컬에서 위 코드를 /tmp/hwp_converter.py로 저장한 후
sudo docker cp /tmp/hwp_converter.py \
  gotenberg-hwp-gotenberg-1:/app/hwp_converter.py
```

### 4. 컨테이너 재시작

```bash
sudo docker restart gotenberg-hwp-gotenberg-1
```

### 5. 로그 확인

```bash
sudo docker logs -f gotenberg-hwp-gotenberg-1
```

## 변경 사항

- **기존**: HWP 전용 엔드포인트
- **변경**: 파일 확장자별 라우팅 추가
  - `.hwp`, `.hwpx` → `_convert_hwp()` (기존 로직)
  - `.pptx`, `.ppt` → `_convert_pptx()` (새로운 로직)

## 차이점

| 항목 | HWP | PPTX |
|------|-----|------|
| 변환 단계 | 2단계 (HWP → ODT → PDF) | 1단계 (PPTX → PDF) |
| 의존성 | pyhwp + LibreOffice | LibreOffice만 |
| 타임아웃 | 60초 (hwp5odt) + 180초 (LO) | 180초 (LO만) |
| 복잡도 | 높음 | 낮음 |

## 테스트

### PPTX 변환 테스트

```bash
curl -X POST -F "file=@test.pptx" \
  https://kkomjang.synology.me:4000/convert \
  -o output.pdf
```

### 4개 동시 요청 테스트

```bash
for i in {1..4}; do
  curl -X POST -F "file=@test.pptx" \
    https://kkomjang.synology.me:4000/convert \
    -o test_${i}.pdf &
done
wait
```

## 장점

1. **간단함**: HWP처럼 중간 변환 단계 없음
2. **안정적**: LibreOffice가 PPTX를 네이티브로 지원
3. **빠름**: 1단계 변환으로 속도 향상
4. **재사용**: 같은 엔드포인트, 같은 인프라 활용

## 추가 확장 가능

같은 방식으로 다른 Office 파일도 지원 가능:
- **DOC/DOCX**: `_convert_docx()` 추가
- **XLS/XLSX**: `_convert_xlsx()` 추가

LibreOffice가 모두 네이티브로 지원하므로 PPTX와 동일한 패턴 사용 가능.
