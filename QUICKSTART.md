# Quick Start for Contributors

New to the project? This guide will get you up and running in 5 minutes.

## Prerequisites

```bash
# Install SwiftLint
brew install swiftlint

# Install SwiftFormat
brew install swiftformat
```

## Get Started

```bash
# Clone the repository
git clone https://github.com/dalemyers/DictionaryCoder.git
cd DictionaryCoder

# Build the project
swift build

# Run tests
swift test

# Check code quality
make lint
```

## Common Tasks

### Make a Change

```bash
# Create a feature branch
git checkout -b feature/my-feature

# Make your changes
# ... edit files ...

# Format your code
make format

# Run all checks
make all

# Commit and push
git add .
git commit -m "Add my feature"
git push origin feature/my-feature
```

### Run Tests

```bash
# Run all tests
swift test

# Run tests with coverage
swift test --enable-code-coverage

# Generate coverage report
./generate_coverage_llvm.sh
open coverage_html/index.html
```

### Check Code Quality

```bash
# Check linting
swiftlint lint --strict

# Check formatting
swiftformat --lint .

# Fix formatting automatically
swiftformat .
```

## Useful Makefile Commands

```bash
make help      # Show all available commands
make build     # Build the project
make test      # Run tests
make lint      # Check code quality
make format    # Format code
make coverage  # Generate coverage report
make clean     # Clean build artifacts
make all       # Format, lint, build, and test
```

## Project Structure

```
DictionaryCoder/
├── Sources/
│   ├── DictionaryDecoder/    # Decoder implementation
│   └── DictionaryEncoder/    # Encoder implementation
└── Tests/
    ├── DictionaryDecoderTests/  # Decoder tests
    └── DictionaryEncoderTests/  # Encoder tests
```

## Need Help?

- Check [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines
- Open a [GitHub Discussion](https://github.com/dalemyers/DictionaryCoder/discussions) for questions
- Review existing issues and PRs for examples

## Quick Tips

1. **Always format before committing**: `make format`
2. **Run all checks locally**: `make all`
3. **Maintain 100% test coverage**: Add tests for new code
4. **Keep PRs focused**: One feature/fix per PR
5. **Write clear commit messages**: Describe what and why

Happy coding! 🎉
