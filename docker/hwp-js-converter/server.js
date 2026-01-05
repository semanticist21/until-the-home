const http = require('http');
const HWP = require('hwp.js');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 3000;
const UPLOAD_DIR = process.env.UPLOAD_DIR || '/tmp/hwp-uploads';

// Ensure upload directory exists
try {
  if (!fs.existsSync(UPLOAD_DIR)) {
    fs.mkdirSync(UPLOAD_DIR, { recursive: true });
  }
} catch (e) {
  console.warn('Could not create upload directory:', e.message);
}

// Extract text from paragraph
function extractText(paragraph) {
  if (!paragraph.content) return '';
  return paragraph.content
    .filter(item => item.type === 0 && typeof item.value === 'string')
    .map(item => item.value)
    .join('');
}

// Convert HWP buffer to HTML
function hwpToHtml(buffer) {
  const parsed = HWP.parse(buffer, { type: 'buffer' });

  let html = `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      font-family: "Apple SD Gothic Neo", "Nanum Gothic", "Malgun Gothic", sans-serif;
      max-width: 800px;
      margin: 40px auto;
      line-height: 1.8;
      padding: 20px;
      color: #333;
    }
    p { margin: 0.5em 0; }
    .empty { height: 1em; }
  </style>
</head>
<body>
`;

  for (const section of parsed.sections) {
    for (const para of section.content) {
      const text = extractText(para);
      if (text.trim()) {
        html += `  <p>${escapeHtml(text)}</p>\n`;
      } else {
        html += `  <p class="empty"></p>\n`;
      }
    }
  }

  html += `</body>
</html>`;

  return html;
}

// Convert HWP buffer to plain text
function hwpToText(buffer) {
  const parsed = HWP.parse(buffer, { type: 'buffer' });
  const lines = [];

  for (const section of parsed.sections) {
    for (const para of section.content) {
      const text = extractText(para);
      lines.push(text);
    }
  }

  return lines.join('\n');
}

// Convert HWP buffer to JSON
function hwpToJson(buffer) {
  const parsed = HWP.parse(buffer, { type: 'buffer' });
  const result = {
    header: parsed.header,
    sections: []
  };

  for (const section of parsed.sections) {
    const paragraphs = [];
    for (const para of section.content) {
      paragraphs.push({
        text: extractText(para),
        textSize: para.textSize
      });
    }
    result.sections.push({
      width: section.width,
      height: section.height,
      paragraphs
    });
  }

  return result;
}

function escapeHtml(text) {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

// Parse multipart form data
function parseMultipart(buffer, boundary) {
  const boundaryBytes = Buffer.from('--' + boundary);
  const parts = [];
  let start = 0;

  while (true) {
    const boundaryIndex = buffer.indexOf(boundaryBytes, start);
    if (boundaryIndex === -1) break;

    const nextBoundaryIndex = buffer.indexOf(boundaryBytes, boundaryIndex + boundaryBytes.length);
    if (nextBoundaryIndex === -1) break;

    const partData = buffer.slice(boundaryIndex + boundaryBytes.length, nextBoundaryIndex);
    const headerEndIndex = partData.indexOf('\r\n\r\n');

    if (headerEndIndex !== -1) {
      const headers = partData.slice(0, headerEndIndex).toString('utf8');
      const body = partData.slice(headerEndIndex + 4);

      // Remove trailing \r\n
      const cleanBody = body.slice(0, body.length - 2);

      const filenameMatch = headers.match(/filename="([^"]+)"/);
      const nameMatch = headers.match(/name="([^"]+)"/);

      parts.push({
        name: nameMatch ? nameMatch[1] : null,
        filename: filenameMatch ? filenameMatch[1] : null,
        data: cleanBody
      });
    }

    start = nextBoundaryIndex;
  }

  return parts;
}

const server = http.createServer(async (req, res) => {
  // CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  // Health check
  if (req.method === 'GET' && req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok', service: 'hwp-js-converter' }));
    return;
  }

  // Convert endpoint
  if (req.method === 'POST' && req.url.startsWith('/convert')) {
    const url = new URL(req.url, `http://${req.headers.host}`);
    const format = url.searchParams.get('format') || 'html';

    const chunks = [];
    req.on('data', chunk => chunks.push(chunk));
    req.on('end', () => {
      try {
        const body = Buffer.concat(chunks);
        const contentType = req.headers['content-type'] || '';

        let fileBuffer;
        let filename = 'document.hwp';

        if (contentType.includes('multipart/form-data')) {
          const boundaryMatch = contentType.match(/boundary=(.+)/);
          if (!boundaryMatch) {
            throw new Error('No boundary in multipart request');
          }

          const parts = parseMultipart(body, boundaryMatch[1]);
          const filePart = parts.find(p => p.filename && p.filename.endsWith('.hwp'));

          if (!filePart) {
            throw new Error('No HWP file found in request');
          }

          fileBuffer = filePart.data;
          filename = filePart.filename;
        } else {
          // Raw binary
          fileBuffer = body;
        }

        console.log(`Converting ${filename} (${fileBuffer.length} bytes) to ${format}`);

        let result, contentTypeHeader;

        switch (format) {
          case 'text':
            result = hwpToText(fileBuffer);
            contentTypeHeader = 'text/plain; charset=utf-8';
            break;
          case 'json':
            result = JSON.stringify(hwpToJson(fileBuffer), null, 2);
            contentTypeHeader = 'application/json; charset=utf-8';
            break;
          case 'html':
          default:
            result = hwpToHtml(fileBuffer);
            contentTypeHeader = 'text/html; charset=utf-8';
            break;
        }

        res.writeHead(200, { 'Content-Type': contentTypeHeader });
        res.end(result);

      } catch (err) {
        console.error('Conversion error:', err);
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: err.message }));
      }
    });
    return;
  }

  // 404
  res.writeHead(404, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ error: 'Not found' }));
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`HWP.js converter server running on port ${PORT}`);
  console.log('Endpoints:');
  console.log('  GET  /health');
  console.log('  POST /convert?format=html|text|json');
});
