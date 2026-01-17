# HWPX to PDF Converter

Java-based HWPX to PDF converter using hwpxlib and Apache PDFBox with Korean font support.

## 📋 Overview

- **Language**: Java 11
- **Libraries**:
  - hwpxlib 1.0.8 (HWPX parsing)
  - Apache PDFBox 2.0.30 (PDF generation)
  - Noto Sans KR (Korean font)
- **Output**: Executable JAR (40MB with embedded font)

## 🚀 Quick Start

### Build

```bash
mvn clean package
```

### Run

```bash
java -jar target/hwpx-converter-1.0.0.jar input.hwpx output.pdf
```

## ✅ Features

- ✅ HWPX text extraction
- ✅ Korean character support (Noto Sans KR)
- ✅ Automatic pagination (A4 size)
- ✅ Multi-line text handling
- ✅ Embedded font (no external dependencies)

## 📁 Project Structure

```
hwpx-converter/
├── src/main/
│   ├── java/com/kkomi/
│   │   └── HwpxToPdfConverter.java    # Main converter
│   └── resources/
│       └── NotoSansKR.ttf              # Korean font (10MB)
├── pom.xml                              # Maven configuration
├── target/
│   └── hwpx-converter-1.0.0.jar        # Executable JAR (40MB)
├── hwpxlib/                            # Test HWPX files
│   └── testFile/reader_writer/        # 28+ sample files
├── flask_integration.py                # Flask API wrapper
├── Dockerfile.patch                    # Docker configuration
├── NAS_DEPLOYMENT.md                   # NAS deployment guide
└── README.md                           # This file
```

## 🧪 Testing

### Local Test

```bash
# Test with sample HWPX
java -jar target/hwpx-converter-1.0.0.jar \
  hwpxlib/testFile/reader_writer/sample1.hwpx \
  /tmp/test.pdf

# Test with Korean text
java -jar target/hwpx-converter-1.0.0.jar \
  hwpxlib/testFile/tool/textextractor/multipara.hwpx \
  /tmp/test_korean.pdf
```

### Test Results

| File | Text Length | Korean Support | Status |
|------|-------------|----------------|--------|
| sample1.hwpx | 17 chars | ✅ | Success |
| multipara.hwpx | 1,154 chars | ✅ | Success |
| Table.hwpx | 69 chars | ✅ | Success |

## 🐳 Flask Integration

### Add to existing Flask app

```python
@app.route('/convert_hwpx', methods=['POST'])
def convert_hwpx():
    # ... (see flask_integration.py)
    result = subprocess.run(
        ['java', '-jar', 'hwpx-converter-1.0.0.jar', input_path, output_path],
        timeout=180
    )
    return send_file(output_path)
```

### Docker Deployment

```dockerfile
# Install Java
RUN apt-get update && \
    apt-get install -y openjdk-17-jre-headless

# Copy JAR
COPY hwpx-converter-1.0.0.jar /app/
```

See `NAS_DEPLOYMENT.md` for detailed deployment instructions.

## 📊 Performance

- **Conversion Speed**: ~1-2 seconds for typical HWPX files
- **Memory Usage**: ~100-200MB (JVM heap)
- **JAR Size**: 40MB (including 10MB Korean font)

## ⚠️ Limitations

1. **Text-only**: No images, shapes, or complex formatting
2. **Simple Layout**: Single-column, left-aligned text
3. **Basic Pagination**: No header/footer preservation
4. **Table Support**: Tables extracted as plain text

## 🔧 Development

### Requirements

- Java 11+
- Maven 3.6+
- Internet connection (for dependency download)

### Dependencies

```xml
<!-- hwpxlib -->
<dependency>
    <groupId>kr.dogfoot</groupId>
    <artifactId>hwpxlib</artifactId>
    <version>1.0.8</version>
</dependency>

<!-- Apache PDFBox -->
<dependency>
    <groupId>org.apache.pdfbox</groupId>
    <artifactId>pdfbox</artifactId>
    <version>2.0.30</version>
</dependency>
```

### Build Configuration

- **Source/Target**: Java 11
- **Packaging**: JAR with dependencies (Maven Shade Plugin)
- **Main Class**: `com.kkomi.HwpxToPdfConverter`

## 📝 API Reference

### Command Line

```bash
java -jar hwpx-converter-1.0.0.jar <input.hwpx> <output.pdf>
```

**Arguments**:
- `input.hwpx`: Path to HWPX file
- `output.pdf`: Path to output PDF file

**Exit Codes**:
- `0`: Success
- `1`: Error (file not found, conversion failed, etc.)

### Flask API

**Endpoint**: `POST /convert_hwpx`

**Request**:
- Content-Type: `multipart/form-data`
- Field: `file` (HWPX file)

**Response**:
- Success: PDF file (application/pdf)
- Error: JSON with error message

## 🚀 Next Steps

1. **Flask Integration**: Add HWPX endpoint to existing HWP converter
2. **Docker Deployment**: Build container with Java + JAR
3. **NAS Integration**: Deploy to Synology NAS with reverse proxy

## 📚 References

- [hwpxlib GitHub](https://github.com/neolord0/hwpxlib)
- [Apache PDFBox](https://pdfbox.apache.org/)
- [Noto Sans KR](https://fonts.google.com/noto/specimen/Noto+Sans+KR)

## 📄 License

This project uses:
- hwpxlib: Apache-2.0 License
- Apache PDFBox: Apache-2.0 License
- Noto Sans KR: SIL Open Font License 1.1
