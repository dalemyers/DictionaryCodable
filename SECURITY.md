# Security Policy

## Supported Versions

The following versions of DictionaryCoder are currently supported with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in DictionaryCoder, please report it responsibly:

### How to Report

**Please do NOT report security vulnerabilities through public GitHub issues.**

Instead, please send an email to:
- **Email**: dale@myers.io
- **Subject**: [SECURITY] DictionaryCoder Security Vulnerability

### What to Include

Please include the following information in your report:

1. **Type of vulnerability** (e.g., code injection, information disclosure, etc.)
2. **Location** (file paths, line numbers, affected components)
3. **Step-by-step instructions** to reproduce the vulnerability
4. **Proof of concept** or exploit code (if available)
5. **Impact assessment** (what could an attacker do with this vulnerability?)
6. **Suggested fix** (if you have one)
7. **Your contact information** for follow-up questions

### What to Expect

- **Acknowledgment**: You'll receive an acknowledgment within 48 hours
- **Initial Assessment**: We'll provide an initial assessment within 5 business days
- **Updates**: We'll keep you informed as we work on a fix
- **Resolution**: We'll work to release a patch as quickly as possible
- **Credit**: If you wish, we'll acknowledge your contribution in the security advisory

### Disclosure Policy

- Please give us reasonable time to fix the vulnerability before public disclosure
- We aim to release security patches within 30 days of confirmation
- We'll coordinate with you on the disclosure timeline
- We'll credit you in the security advisory (unless you prefer to remain anonymous)

## Security Best Practices

When using DictionaryCoder:

1. **Validate Input**: Always validate dictionary data from untrusted sources
2. **Handle Errors**: Properly handle decoding errors to avoid exposing sensitive information
3. **Type Safety**: Use specific types rather than `Any` where possible
4. **Access Control**: Be cautious about what data you decode from external sources
5. **Dependencies**: Keep your Swift version and dependencies up to date

## Known Security Considerations

### Dictionary Sources

DictionaryCoder decodes data from dictionaries. Always be cautious when:
- Decoding data from untrusted sources
- Decoding data that could contain malicious values
- Exposing error messages to end users (they may contain sensitive information)

### Type Coercion

DictionaryCoder performs type coercion (e.g., converting doubles to integers). Be aware:
- Numeric conversions may truncate values
- Large numbers may overflow when converting to smaller types
- The library detects overflows and throws errors, but validate inputs when possible

## Security Updates

Security updates will be:
- Released as patch versions (e.g., 1.0.1)
- Announced in GitHub Security Advisories
- Documented in CHANGELOG.md
- Tagged with appropriate CVE identifiers when applicable

## Contact

For security concerns, contact:
- **Email**: dale@myers.io
- **Response Time**: Within 48 hours

For general issues and questions, use [GitHub Issues](https://github.com/dalemyers/DictionaryCoder/issues).

Thank you for helping keep DictionaryCoder secure! 🔒
