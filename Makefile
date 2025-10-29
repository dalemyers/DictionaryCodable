.PHONY: help build test lint format coverage clean all

help:
	@echo "DictionaryCoder Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  build      - Build the project"
	@echo "  test       - Run tests"
	@echo "  lint       - Run SwiftLint and SwiftFormat checks"
	@echo "  format     - Format code with SwiftFormat"
	@echo "  coverage   - Generate code coverage report"
	@echo "  clean      - Clean build artifacts"
	@echo "  all        - Run format, lint, build, and test"

build:
	@echo "🔨 Building..."
	@swift build

test:
	@echo "🧪 Running tests..."
	@swift test

lint:
	@echo "🔍 Running SwiftLint..."
	@swiftlint lint --strict
	@echo "🔍 Running SwiftFormat (lint mode)..."
	@swiftformat --lint .

format:
	@echo "✨ Formatting code with SwiftFormat..."
	@swiftformat .

coverage:
	@echo "📊 Generating coverage report..."
	@./generate_coverage_llvm.sh

clean:
	@echo "🧹 Cleaning build artifacts..."
	@swift package clean
	@rm -rf .build
	@rm -rf coverage_report
	@rm -rf coverage_html

all: format lint build test
	@echo "✅ All checks passed!"
