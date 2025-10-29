#!/bin/bash
#
# generate_coverage_llvm.sh
# Simple script to generate HTML coverage report using llvm-cov
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPORT_DIR="coverage_html"
PLATFORM="arm64-apple-macosx"  # Change to x86_64-apple-macosx for Intel Macs

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}           Swift Code Coverage Report (llvm-cov)${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo ""

# Step 1: Clean previous build
echo -e "${YELLOW}[1/4] Cleaning previous build...${NC}"
swift package clean
rm -rf "$REPORT_DIR"
echo -e "${GREEN}✓ Clean complete${NC}"
echo ""

# Step 2: Run tests with code coverage
echo -e "${YELLOW}[2/4] Running tests with code coverage...${NC}"
if swift test --enable-code-coverage; then
    echo -e "${GREEN}✓ All tests passed${NC}"
else
    echo -e "${RED}✗ Tests failed${NC}"
    exit 1
fi
echo ""

# Step 3: Find required files
echo -e "${YELLOW}[3/4] Locating coverage data...${NC}"

XCTEST_PATH=".build/$PLATFORM/debug/DictionaryCoderPackageTests.xctest/Contents/MacOS/DictionaryCoderPackageTests"
PROFDATA_PATH=".build/$PLATFORM/debug/codecov/default.profdata"

if [ ! -f "$XCTEST_PATH" ]; then
    echo -e "${RED}✗ Test binary not found at: $XCTEST_PATH${NC}"
    echo -e "${YELLOW}  Tip: If you're on Intel Mac, change PLATFORM to 'x86_64-apple-macosx'${NC}"
    exit 1
fi

if [ ! -f "$PROFDATA_PATH" ]; then
    echo -e "${RED}✗ Coverage data not found at: $PROFDATA_PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Coverage data found${NC}"
echo ""

# Step 4: Generate HTML report using llvm-cov
echo -e "${YELLOW}[4/4] Generating HTML report with llvm-cov...${NC}"

xcrun llvm-cov show \
    "$XCTEST_PATH" \
    -instr-profile="$PROFDATA_PATH" \
    -format=html \
    -output-dir="$REPORT_DIR" \
    -ignore-filename-regex='\.build|Tests'

echo -e "${GREEN}✓ HTML report generated${NC}"
echo ""

# Final summary
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Coverage report complete!${NC}"
echo ""
echo -e "  📊 Report location: ${YELLOW}$REPORT_DIR/index.html${NC}"
echo ""
echo -e "  To view the report:"
echo -e "    ${YELLOW}open $REPORT_DIR/index.html${NC}"
echo ""
echo -e "  Report includes:"
echo -e "    • Source-level coverage highlighting"
echo -e "    • Function-level statistics"
echo -e "    • File-level summaries"
echo -e "    • Line-by-line annotations"
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"

# Automatically open the report
open "$REPORT_DIR/index.html"
