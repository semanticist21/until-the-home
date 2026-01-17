# Document Conversion Test Results

## Test Date: 2026-01-17

### Summary
- **Total Tests**: 8
- **Passed**: 8 (100%)
- **Failed**: 0
- **Total Time**: 6.16 seconds

## Real Sample Files (Downloaded)

| File | Size | Type | Source | Conversion Time | PDF Size |
|------|------|------|--------|----------------|----------|
| sample.doc | 25KB | DOC (binary, legacy) | filesamples.com | 1.32s | 41KB |
| sample.docx | 1.3MB | DOCX (Office 2007+) | calibre-ebook.com | 1.15s | 111KB |
| sample.xls | 16KB | XLS (binary, Excel 2012) | filesamples.com | 0.49s | 72KB |
| sample.xlsx | 29KB | XLSX (Office 2007+) | filesamples.com | 0.64s | 35KB |
| sample.ppt | 891KB | PPT (PowerPoint 2005) | filesamples.com | 1.10s | 286KB |

## Created Sample Files (Python zipfile + OOXML)

| File | Size | Type | Method | Conversion Time | PDF Size |
|------|------|------|--------|----------------|----------|
| sample.pptx | 1.6KB | PPTX (minimal valid) | Python zipfile | 0.42s | 12KB |
| test_sample.xlsx | 1.5KB | XLSX (minimal valid) | Python zipfile | 0.53s | 13KB |
| test_sample.pptx | 1.6KB | PPTX (minimal valid) | Python zipfile | 0.51s | 12KB |

## API Endpoints Used

| Format | Endpoint | Method |
|--------|----------|--------|
| DOC, DOCX | `https://kkomjang.synology.me:4000/forms/libreoffice/convert` | Gotenberg |
| XLS, XLSX | `https://kkomjang.synology.me:4000/forms/libreoffice/convert` | Gotenberg |
| PPT, PPTX | `https://kkomjang.synology.me:4000/forms/libreoffice/convert` | Gotenberg |
| HWP | `https://kkomjang.synology.me:4000/convert` | Flask (not tested) |
| HWPX | `https://kkomjang.synology.me:4000/convert_hwpx` | Flask (not tested) |

## Test Details

All Office documents (DOC, DOCX, XLS, XLSX, PPT, PPTX) successfully converted to PDF using the Gotenberg LibreOffice endpoint with Basic Authentication (kkomi:kkomi).

### Authentication
```bash
curl -X POST -F "files=@document.xlsx" \
  -u kkomi:kkomi \
  https://kkomjang.synology.me:4000/forms/libreoffice/convert \
  -o output.pdf
```

### Performance Metrics
- Average conversion time: 0.77 seconds
- Fastest conversion: 0.42s (PPTX, 1.6KB)
- Slowest conversion: 1.32s (DOC, 25KB)
- Total processing time for 8 files: 6.16s

## Missing Formats

### HWP/HWPX
Korean document formats (Hancom Office) could not be sourced from free online repositories. These formats require:
- Korean language resources
- Hancom Office sample files
- Or access to Korean government/education document samples

## Test Script

The test automation script is located at:
- `/Users/semanticist/Documents/code/kkomi/test_samples/test_conversions.py`

Run tests with:
```bash
python3 test_conversions.py
```

## Notes

1. All real Office documents successfully downloaded from public sources
2. PPTX sample from filesamples.com returned HTML (404), so minimal PPTX created using Python instead
3. All conversions completed without errors
4. PDF output files verified as valid PDFs with correct sizes
5. Test script includes colored output, timing, and size metrics
