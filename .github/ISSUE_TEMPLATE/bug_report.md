---
name: Bug Report
about: Report a bug or unexpected behavior
title: '[BUG] '
labels: bug
assignees: ''
---

## Description

A clear and concise description of the bug.

## Steps to Reproduce

1. 
2. 
3. 

## Expected Behavior

What you expected to happen.

## Actual Behavior

What actually happened.

## Code Sample

```swift
// Minimal code sample that reproduces the issue
let dictionary: [String: Any] = [
    "key": "value"
]

let decoder = DictionaryCoder()
let result = try decoder.decode(MyType.self, from: dictionary)
```

## Environment

- **DictionaryCoder Version**: (e.g., 1.0.0)
- **Swift Version**: (run `swift --version`)
- **Platform**: (e.g., macOS 14.0, iOS 17.0, Linux Ubuntu 22.04)
- **Xcode Version** (if applicable): (e.g., 26.0)

## Additional Context

Any other information that might be helpful in diagnosing the issue.

## Possible Solution

If you have suggestions on how to fix this, please share them here.
