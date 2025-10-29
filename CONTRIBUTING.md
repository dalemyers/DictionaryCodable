# Contributing to DictionaryCoder

Thank you for your interest in contributing to DictionaryCoder! This document provides guidelines and instructions for contributing to the project.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for all contributors.

## How to Contribute

### Reporting Bugs

Before creating a bug report, please check existing issues to avoid duplicates. When filing a bug report, include:

- A clear, descriptive title
- Steps to reproduce the issue
- Expected behavior vs. actual behavior
- Swift version and platform information
- Code samples demonstrating the issue (if applicable)

### Suggesting Enhancements

Enhancement suggestions are welcome! Please include:

- A clear description of the enhancement
- Use cases and benefits
- Example code showing the proposed API (if applicable)
- Any potential drawbacks or considerations

### Pull Requests

1. **Fork the repository** and create your feature branch from `main`
   ```bash
   git checkout -b feature/my-new-feature
   ```

2. **Make your changes** following the project's coding standards
   - Follow Swift naming conventions
   - Maintain consistency with existing code style
   - Add documentation for public APIs
   - Include examples for new features

3. **Add tests** for all new functionality
   - Maintain 100% code coverage
   - Test both success and failure cases
   - Test edge cases and boundary conditions

4. **Run quality checks** before submitting
   ```bash
   # Format code
   swiftformat .
   
   # Lint code
   swiftlint lint --strict
   swiftformat --lint .
   
   # Build and test
   swift build
   swift test
   
   # Verify coverage
   ./generate_coverage_llvm.sh
   ```

5. **Commit your changes** with clear, descriptive messages
   - Use present tense ("Add feature" not "Added feature")
   - Reference issue numbers when applicable
   - Keep commits focused and atomic

6. **Push to your fork** and submit a pull request
   ```bash
   git push origin feature/my-new-feature
   ```

7. **Respond to feedback** during code review
   - Address reviewer comments promptly
   - Update tests as needed
   - Keep the PR scope focused

## Development Setup

### Testing Guidelines

- Write tests for all new functionality
- Maintain 100% code coverage for lines, functions, and regions
- Use descriptive test names that explain what is being tested
- Test both success and failure paths
- Test edge cases and boundary conditions
- Group related tests in the same file
- Keep test models and fixtures close to the tests that use them

### Documentation

- Add documentation comments (`///`) for all public APIs
- Include usage examples in documentation
- Update README.md for significant new features
- Keep examples simple and focused
- Update CHANGELOG.md with your changes

## Project Structure

```
DictionaryCoder/
├── Sources/
│   ├── DictionaryDecoder/     # Decoder implementation
│   └── DictionaryEncoder/     # Encoder implementation
├── Tests/
│   ├── DictionaryDecoderTests/  # Decoder tests
│   └── DictionaryEncoderTests/  # Encoder tests
├── .github/workflows/         # CI/CD workflows
├── README.md                  # Main documentation
├── CHANGELOG.md              # Version history
├── LICENSE                   # MIT license
└── Package.swift             # Swift package manifest
```

## Review Process

1. All pull requests require review before merging
2. CI checks must pass (build, tests, linting, formatting)
3. Code coverage must remain at 100%
4. Changes should be backwards compatible when possible
5. Breaking changes require major version bump

## Release Process

Releases are managed by the maintainers. The process:

1. Update version in relevant files
2. Update CHANGELOG.md
3. Create a git tag (e.g., `v1.0.0`)
4. Push the tag to trigger release workflow
5. GitHub Actions automatically:
   - Creates a GitHub release
   - Publishes to CocoaPods (requires `COCOAPODS_TRUNK_TOKEN` secret)

### CocoaPods Setup

For maintainers publishing to CocoaPods, you need to set up the `COCOAPODS_TRUNK_TOKEN` secret in the GitHub repository:

1. Register with CocoaPods trunk: `pod trunk register email@example.com 'Your Name'`
2. Get your session token from `~/.netrc`
3. Add it as a repository secret named `COCOAPODS_TRUNK_TOKEN`

## Questions?

- Open a [GitHub Discussion](https://github.com/dalemyers/DictionaryCoder/discussions) for questions
- Check existing issues and discussions first
- Be clear and concise in your questions

## License

By contributing to DictionaryCoder, you agree that your contributions will be licensed under the MIT License.

Thank you for contributing! 🎉
