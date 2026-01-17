# NAS 배포 가이드: HWPX 변환 기능 추가

## 1. 준비물

### 로컬 파일
- `/Users/semanticist/Documents/code/kkomi/test_samples/hwpx-converter/target/hwpx-converter-1.0.0.jar` (40MB)
- `/Users/semanticist/Documents/code/kkomi/test_samples/hwpx-converter/flask_integration.py`

## 2. NAS 배포 단계

### 2.1. JAR 파일 복사

```bash
# 로컬에서 실행
scp /Users/semanticist/Documents/code/kkomi/test_samples/hwpx-converter/target/hwpx-converter-1.0.0.jar \
    semanticist@192.168.0.171:/volume1/docker/gotenberg-hwp/
```

### 2.2. NAS 접속 및 Flask 앱 수정

```bash
# NAS 접속
ssh semanticist@192.168.0.171
# password: wldnjsqkr14!

# Docker 작업 디렉토리로 이동
cd /volume1/docker/gotenberg-hwp/

# 기존 hwp_converter.py 백업
sudo cp hwp_converter.py hwp_converter.py.backup
```

### 2.3. Flask 앱에 HWPX 엔드포인트 추가

기존 `hwp_converter.py`에 다음 함수 추가:

```python
@app.route('/convert_hwpx', methods=['POST'])
def convert_hwpx():
    """Convert HWPX files to PDF using Java hwpxlib"""
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400

    if not file.filename.lower().endswith('.hwpx'):
        return jsonify({'error': 'Only HWPX files are supported'}), 400

    try:
        with tempfile.TemporaryDirectory() as work_dir:
            hwpx_filename = secure_filename(file.filename)
            hwpx_path = os.path.join(work_dir, hwpx_filename)
            file.save(hwpx_path)

            pdf_filename = os.path.splitext(hwpx_filename)[0] + '.pdf'
            pdf_path = os.path.join(work_dir, pdf_filename)

            jar_path = '/app/hwpx-converter-1.0.0.jar'
            result = subprocess.run(
                ['java', '-jar', jar_path, hwpx_path, pdf_path],
                capture_output=True,
                text=True,
                timeout=180,
                env={'HOME': work_dir}
            )

            if result.returncode != 0:
                app.logger.error(f"Java conversion failed: {result.stderr}")
                return jsonify({'error': 'HWPX conversion failed', 'details': result.stderr}), 500

            if not os.path.exists(pdf_path):
                return jsonify({'error': 'PDF file not generated'}), 500

            app.logger.info(f"Successfully converted {hwpx_filename} to PDF")

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
```

### 2.4. Dockerfile 수정

```bash
# Dockerfile 편집
sudo vi Dockerfile

# Python 설치 후에 다음 추가:
# Install OpenJDK 17 for HWPX converter
RUN apt-get update && \
    apt-get install -y openjdk-17-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy HWPX converter JAR file
COPY hwpx-converter-1.0.0.jar /app/hwpx-converter-1.0.0.jar

# Verify Java installation
RUN java -version
```

### 2.5. Docker 이미지 재빌드 및 재시작

```bash
# Docker 컨테이너 중지
sudo docker stop gotenberg-hwp-gotenberg-1

# Docker 이미지 재빌드
cd /volume1/docker/gotenberg-hwp/
sudo docker-compose build

# Docker 컨테이너 재시작
sudo docker-compose up -d

# 로그 확인
sudo docker logs -f gotenberg-hwp-gotenberg-1

# Java 설치 확인
sudo docker exec gotenberg-hwp-gotenberg-1 java -version
```

## 3. 테스트

### 3.1. 로컬에서 테스트

```bash
# HWPX 변환 테스트 (내부 네트워크)
curl -X POST -F "file=@sample.hwpx" \
  http://192.168.0.171:3131/convert_hwpx \
  -o output.pdf

# HWPX 변환 테스트 (외부 네트워크)
curl -X POST -F "file=@sample.hwpx" \
  https://kkomjang.synology.me:4000/convert_hwpx \
  -o output.pdf

# 기존 HWP 변환도 여전히 작동 확인
curl -X POST -F "file=@sample.hwp" \
  https://kkomjang.synology.me:4000/convert \
  -o output_hwp.pdf
```

### 3.2. Health Check

```bash
curl http://192.168.0.171:3131/health
# Expected: {"status":"ok","converters":["hwp","hwpx"]}
```

## 4. 엔드포인트 정리

| 포트 | 엔드포인트 | 용도 | 지원 포맷 |
|------|-----------|------|----------|
| 4000 | `/convert` | HWP 변환 | HWP |
| 4000 | `/convert_hwpx` | HWPX 변환 | HWPX |
| 4001 | `/forms/libreoffice/convert` | Office 변환 | DOC/XLS/PPT/DOCX/XLSX/PPTX |

## 5. 배포 완료 확인

✅ **완료된 작업** (2026.01.17):
- JAR 파일 업로드 (40.1MB, Noto Sans KR 폰트 포함)
- Flask 앱 `/convert_hwpx` 엔드포인트 추가
- Dockerfile에 OpenJDK 21 설치
- Docker 이미지 빌드 및 컨테이너 재시작
- 내부 포트 3131 테스트 성공 (PDF 생성 확인)
- Reverse proxy 설정 수정 (3001 → 3131)
- 외부 포트 4000 테스트 성공 (https://kkomjang.synology.me:4000/convert_hwpx)

🎉 **배포 완료!** HWPX → PDF 변환 서비스가 정상 작동합니다.

## 8. 트러블슈팅

### Java가 없다고 나오는 경우
```bash
sudo docker exec gotenberg-hwp-gotenberg-1 apt-get update
sudo docker exec gotenberg-hwp-gotenberg-1 apt-get install -y openjdk-21-jre-headless
sudo docker restart gotenberg-hwp-gotenberg-1
```

### JAR 파일을 찾을 수 없는 경우
```bash
# 컨테이너 내부에서 파일 확인
sudo docker exec gotenberg-hwp-gotenberg-1 ls -lh /app/

# JAR 파일 복사 (컨테이너 실행 중)
sudo docker cp hwpx-converter-1.0.0.jar gotenberg-hwp-gotenberg-1:/app/
sudo docker restart gotenberg-hwp-gotenberg-1
```

### 한글이 깨지는 경우
- JAR 파일에 Noto Sans KR 폰트가 임베딩되어 있어야 함
- 로컬에서 빌드한 JAR 파일 사용 확인

### 외부 접속 시 502 에러가 발생하는 경우
**증상**: `https://kkomjang.synology.me:4000/convert_hwpx` 접속 시 502 Bad Gateway 에러

**원인**: Reverse proxy 설정에서 backend 포트가 잘못 설정됨 (3001로 설정되어 있으나 Flask는 3131에서 실행 중)

**해결 방법**:
```bash
# ReverseProxy.json 파일 수정
sudo vim /usr/syno/etc/www/ReverseProxy.json
# "port" : 3001 → "port" : 3131로 변경

# Nginx 재시작 (설정 재생성)
sudo systemctl restart nginx

# 또는 synow3tool 사용
sudo /usr/syno/bin/synow3tool --nginx=reload
```

**확인 방법**:
```bash
# w3conf 파일에서 올바른 포트 확인
sudo cat /usr/local/etc/nginx/sites-available/*.w3conf | grep proxy_pass
# 출력: proxy_pass http://localhost:3131; (정상)

# 외부 테스트
curl -X POST -F "file=@sample.hwpx" https://kkomjang.synology.me:4000/convert_hwpx -o output.pdf
# HTTP 200 응답 시 정상
```

## 6. Reverse Proxy 설정 (중요!)

**⚠️ 외부 접속을 위해서는 Synology Reverse Proxy 설정 필요**

### 6.1. Reverse Proxy 규칙 추가

Synology DSM → 제어판 → 로그인 포털 → 고급 → Reverse Proxy

**새 규칙 추가: HWPX 변환**

| 항목 | 값 |
|------|-----|
| 이름 | HWPX Converter |
| 프로토콜 | HTTPS |
| 포트 | 4000 |
| 경로 | `/convert_hwpx` |
| 대상 프로토콜 | HTTP |
| 대상 호스트 | localhost |
| 대상 포트 | 3131 |
| 대상 경로 | `/convert_hwpx` |

### 6.2. 기존 규칙 확인

기존 HWP 변환 규칙도 있어야 함:
- `/convert` → `localhost:3131/convert`

### 6.3. 테스트

```bash
# 내부 네트워크 (항상 작동)
curl -X POST -F "file=@sample.hwpx" http://192.168.0.171:3131/convert_hwpx -o output.pdf

# 외부 네트워크 (reverse proxy 설정 후)
curl -X POST -F "file=@sample.hwpx" https://kkomjang.synology.me:4000/convert_hwpx -o output.pdf
```

## 7. Flutter 앱 통합

Flutter 앱의 `nas_to_pdf_converter.dart`에서 HWPX 파일을 다음과 같이 처리:

```dart
// HWPX 파일인 경우
if (filePath.toLowerCase().endsWith('.hwpx')) {
  final uri = Uri.parse('https://kkomjang.synology.me:4000/convert_hwpx');
  // ... 기존 NAS 변환 로직 사용
}
```
