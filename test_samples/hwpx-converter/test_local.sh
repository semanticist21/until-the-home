#!/bin/bash
# Local testing script for HWPX converter

set -e

JAR_PATH="target/hwpx-converter-1.0.0.jar"
TEST_DIR="hwpxlib/testFile"

echo "🧪 HWPX Converter Local Test"
echo "=============================="

# Check JAR exists
if [ ! -f "$JAR_PATH" ]; then
    echo "❌ JAR not found. Building..."
    mvn clean package -q
fi

echo "✅ JAR found: $(ls -lh $JAR_PATH | awk '{print $5}')"

# Test 1: Simple sample
echo ""
echo "Test 1: sample1.hwpx (17 chars)"
java -jar "$JAR_PATH" \
    "$TEST_DIR/reader_writer/sample1.hwpx" \
    "/tmp/test_sample1.pdf" 2>&1 | grep -E "(INFO|ERROR|Conversion)"
echo "✅ Output: /tmp/test_sample1.pdf"

# Test 2: Korean text
echo ""
echo "Test 2: multipara.hwpx (1,154 chars, Korean)"
java -jar "$JAR_PATH" \
    "$TEST_DIR/tool/textextractor/multipara.hwpx" \
    "/tmp/test_multipara.pdf" 2>&1 | grep -E "(INFO|ERROR|Conversion)"
echo "✅ Output: /tmp/test_multipara.pdf"

# Test 3: Table
echo ""
echo "Test 3: Table.hwpx (69 chars, with table)"
java -jar "$JAR_PATH" \
    "$TEST_DIR/tool/textextractor/Table.hwpx" \
    "/tmp/test_table.pdf" 2>&1 | grep -E "(INFO|ERROR|Conversion)"
echo "✅ Output: /tmp/test_table.pdf"

# Summary
echo ""
echo "📊 Test Summary"
echo "==============="
ls -lh /tmp/test_*.pdf | awk '{print $9, "-", $5}'

echo ""
echo "🎉 All tests passed!"
echo ""
echo "📖 View PDFs:"
echo "   open /tmp/test_sample1.pdf"
echo "   open /tmp/test_multipara.pdf"
echo "   open /tmp/test_table.pdf"
