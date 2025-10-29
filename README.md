# DictionaryCoder

[![Swift](https://img.shields.io/badge/Swift-6.0.2+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platforms-iOS%20|%20macOS%20|%20tvOS%20|%20watchOS%20|%20visionOS%20|%20Linux-lightgrey.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![CI](https://github.com/dalemyers/DictionaryCoder/workflows/Pull%20Request%20CI/badge.svg)](https://github.com/dalemyers/DictionaryCoder/actions)
[![codecov](https://codecov.io/gh/dalemyers/DictionaryCoder/branch/main/graph/badge.svg)](https://codecov.io/gh/dalemyers/DictionaryCoder)

A lightweight, high-performance Swift package for encoding and decoding `Codable` types directly to and from dictionaries (`[String: Any]`). Perfect for working with untyped dictionaries from JSON APIs, user defaults, or any source that provides data as dictionaries.

## Why DictionaryCoder?

When working with APIs or data sources that provide dictionaries, you often need to convert between `[String: Any]` and your Swift `Codable` types. While `JSONEncoder`/`JSONDecoder` require intermediate JSON data, `DictionaryCoder` works directly with dictionaries, eliminating unnecessary serialization steps and improving performance.

**Use DictionaryCoder when you:**
- Have dictionary data that doesn't need JSON serialization
- Want type-safe conversion from untyped dictionaries
- Need to work with APIs that return `[String: Any]` directly
- Want to avoid the overhead of JSON encoding/decoding
- Need to convert `Codable` types to dictionaries for storage or transmission

## Features

- ✅ **DictionaryCoder**: Encode/Decode dictionaries to `Codable` types with full type safety
- ✅ **Nested Structures**: Full support for complex nested objects and arrays
- ✅ **Type Safety**: Safe numeric conversions with overflow detection
- ✅ **Optionals**: Proper handling of optional values and nil
- ✅ **Error Handling**: Comprehensive, informative error messages with coding paths
- ✅ **User Info**: Support for `userInfo` dictionaries for custom encoding/decoding logic
- ✅ **100% Test Coverage**: Extensively tested with comprehensive test suite
- ✅ **Zero Dependencies**: Pure Swift implementation

## Installation

### Swift Package Manager

Add `DictionaryCoder` to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/dalemyers/DictionaryCoder.git", from: "1.0.0")
]
```

Or in Xcode, go to **File** → **Add Package Dependencies** and enter the repository URL.

### CocoaPods

Add `DictionaryCoder` to your `Podfile`:

```ruby
pod 'DictionaryCoder', '~> 1.0'
```

Then run:

```bash
pod install
```

## Usage

### Basic Decoding

Convert a dictionary to a `Codable` type:

```swift
import DictionaryCoder

struct Person: Codable {
    let name: String
    let age: Int
    let email: String
}

let dictionary: [String: Any] = [
    "name": "Jane Smith",
    "age": 28,
    "email": "jane@example.com"
]

let decoder = DictionaryCoder()
let person = try decoder.decode(Person.self, from: dictionary)
print(person.name) // "Jane Smith"
```

### Basic Encoding

Convert a `Codable` type to a dictionary:

```swift
import DictionaryCoder

let person = Person(name: "Jane Smith", age: 28, email: "jane@example.com")

let encoder = DictionaryEncoder()
let dictionary = try encoder.encode(person)
// Result: ["name": "Jane Smith", "age": 28, "email": "jane@example.com"]
```

### Nested Structures

DictionaryCoder handles complex nested structures seamlessly:

```swift
struct Address: Codable {
    let street: String
    let city: String
    let zipCode: String
}

struct Company: Codable {
    let name: String
    let employees: [Person]
    let headquarters: Address
}

let companyDict: [String: Any] = [
    "name": "Tech Corp",
    "employees": [
        ["name": "Alice", "age": 30, "email": "alice@techcorp.com"],
        ["name": "Bob", "age": 25, "email": "bob@techcorp.com"]
    ],
    "headquarters": [
        "street": "123 Tech Street",
        "city": "San Francisco",
        "zipCode": "94102"
    ]
]

let decoder = DictionaryCoder()
let company = try decoder.decode(Company.self, from: companyDict)
print(company.employees.count) // 2
```

### Optional Values

DictionaryCoder properly handles optional values and missing keys:

```swift
struct Product: Codable {
    let id: Int
    let name: String
    let description: String?
    let price: Double?
}

let productDict: [String: Any] = [
    "id": 42,
    "name": "Widget"
    // description and price are missing
]

let decoder = DictionaryCoder()
let product = try decoder.decode(Product.self, from: productDict)
print(product.description) // nil
print(product.price) // nil
```

### Numeric Conversions

DictionaryCoder performs safe numeric conversions with overflow detection:

```swift
struct Data: Codable {
    let count: Int
    let value: Double
}

let dict: [String: Any] = [
    "count": 42.7,      // Double → Int (truncates)
    "value": 100        // Int → Double (converts)
]

let decoder = DictionaryCoder()
let data = try decoder.decode(Data.self, from: dict)
print(data.count) // 42
print(data.value) // 100.0
```

### Arrays and Collections

Full support for arrays and nested collections:

```swift
struct TodoList: Codable {
    let title: String
    let items: [String]
    let tags: [String]?
}

let todoDict: [String: Any] = [
    "title": "Shopping List",
    "items": ["Milk", "Bread", "Eggs"],
    "tags": ["groceries", "weekly"]
]

let decoder = DictionaryCoder()
let todo = try decoder.decode(TodoList.self, from: todoDict)
print(todo.items) // ["Milk", "Bread", "Eggs"]
```

### Custom Coding Keys

DictionaryCoder respects custom coding keys:

```swift
struct User: Codable {
    let username: String
    let emailAddress: String
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case username
        case emailAddress = "email"
        case isActive = "active"
    }
}

let userDict: [String: Any] = [
    "username": "johndoe",
    "email": "john@example.com",
    "active": true
]

let decoder = DictionaryCoder()
let user = try decoder.decode(User.self, from: userDict)
print(user.emailAddress) // "john@example.com"
```

### Round-Trip Encoding and Decoding

Encode and decode to verify data integrity:

```swift
let original = Person(name: "Alice", age: 30, email: "alice@example.com")

let encoder = DictionaryEncoder()
let dictionary = try encoder.encode(original)

let decoder = DictionaryCoder()
let decoded = try decoder.decode(Person.self, from: dictionary)

print(decoded.name == original.name) // true
```

### Error Handling

DictionaryCoder provides detailed error information:

```swift
struct StrictData: Codable {
    let requiredField: String
    let requiredNumber: Int
}

let invalidDict: [String: Any] = [
    "requiredField": "value"
    // requiredNumber is missing
]

do {
    let decoder = DictionaryCoder()
    let data = try decoder.decode(StrictData.self, from: invalidDict)
} catch DecodingError.keyNotFound(let key, let context) {
    print("Missing key: \(key)")
    print("Path: \(context.codingPath)")
} catch {
    print("Error: \(error)")
}
```

### User Info

Pass custom information to your encoding/decoding logic:

```swift
let customKey = CodingUserInfoKey(rawValue: "customBehavior")!

let decoder = DictionaryCoder()
decoder.userInfo[customKey] = "special"

// Use in your custom init(from:) implementation
```

## Requirements

- Swift 6.0.2 or later
- Xcode 26.0 or later (for iOS/macOS development)

## API Documentation

### DictionaryCoder

The main decoder class for converting dictionaries to `Codable` types.

```swift
public final class DictionaryCoder {
    public init()
    public var userInfo: [CodingUserInfoKey: Any]
    public func decode<T: Decodable>(_ type: T.Type, from dictionary: [String: Any]) throws -> T
}
```

### DictionaryEncoder

The main encoder class for converting `Codable` types to dictionaries.

```swift
public final class DictionaryEncoder {
    public init()
    public var userInfo: [CodingUserInfoKey: Any]
    public func encode(_ value: some Encodable) throws -> [String: Any]
}
```

## Common Use Cases

### Working with API Responses

```swift
// API returns [String: Any] dictionary
let apiResponse = networkLayer.fetchUserData()

let decoder = DictionaryCoder()
let user = try decoder.decode(User.self, from: apiResponse)
```

### UserDefaults Storage

```swift
// Save to UserDefaults
let settings = AppSettings(theme: "dark", notifications: true)
let encoder = DictionaryEncoder()
let dict = try encoder.encode(settings)
UserDefaults.standard.set(dict, forKey: "appSettings")

// Load from UserDefaults
if let dict = UserDefaults.standard.dictionary(forKey: "appSettings") {
    let decoder = DictionaryCoder()
    let settings = try decoder.decode(AppSettings.self, from: dict)
}
```

### Firebase/Firestore Integration

```swift
// Decode Firestore document
let documentData = document.data() // [String: Any]
let decoder = DictionaryCoder()
let post = try decoder.decode(Post.self, from: documentData)

// Encode for Firestore
let encoder = DictionaryEncoder()
let data = try encoder.encode(post)
firestore.collection("posts").document(id).setData(data)
```

## Performance Characteristics

DictionaryCoder is designed for performance:

- **Zero Copy**: Works directly with dictionaries without intermediate representations
- **Type Safe**: Compile-time type checking with runtime validation
- **Memory Efficient**: No JSON serialization overhead
- **Fast**: Direct value extraction and type conversion

## Limitations

- Top-level encoded values must be dictionaries (keyed containers), not arrays or single values
- Currently supports `[String: Any]` dictionaries only
- Number conversions follow Swift's type coercion rules (may truncate or lose precision)

## Development

### Building the Project

```bash
swift build
```

### Running Tests

```bash
swift test
```

All tests pass with 100% code coverage for lines, functions, and regions.

### Code Coverage

Generate and view HTML code coverage reports:

```bash
./generate_coverage_llvm.sh
```

Open `coverage_html/index.html` in your browser to view the detailed coverage report.

### Code Quality Tools

This project maintains high code quality standards using:

- **SwiftLint**: Enforces Swift style and conventions
- **SwiftFormat**: Ensures consistent code formatting (Nick Lockwood version)

#### Installation

```bash
brew install swiftlint swiftformat
```

#### Running Linters

```bash
# Check for linting issues
swiftlint lint

# Check formatting issues (doesn't modify files)
swiftformat --lint .

# Apply formatting (modifies files)
swiftformat .
```

Configuration files:
- `.swiftlint.yml` - SwiftLint rules and settings
- `.swiftformat` - SwiftFormat options

### Continuous Integration

GitHub Actions workflows ensure code quality:

#### Pull Request Workflow (`.github/workflows/pr.yml`)
Runs on every pull request:
- Lints code with SwiftLint
- Checks formatting with SwiftFormat
- Builds the project
- Runs all tests
- Generates code coverage reports
- Uploads coverage to Codecov

#### Release Workflow (`.github/workflows/release.yml`)
Runs on tagged commits (e.g., `v1.0.0`):
- Performs all PR checks
- Creates GitHub releases automatically
- Publishes release artifacts

## Contributing

Contributions are welcome! Here's how to contribute:

1. **Fork the repository** and create a feature branch
2. **Make your changes** following the project's coding standards
3. **Add tests** for new functionality (maintain 100% coverage)
4. **Run quality checks**:
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
5. **Submit a pull request** with a clear description of changes

### Contribution Guidelines

- Maintain 100% test coverage
- Follow existing code style and conventions
- Add documentation for new public APIs
- Include usage examples for new features
- Ensure all CI checks pass
- Write clear, descriptive commit messages

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Dale Myers

## Acknowledgments

- Built with Swift 6.0.2
- Inspired by the Swift `Codable` system
- Uses the `Encoder` and `Decoder` protocols from Swift's Foundation framework

## Support

- **Issues**: Report bugs or request features via [GitHub Issues](https://github.com/dalemyers/DictionaryCoder/issues)
- **Discussions**: Ask questions in [GitHub Discussions](https://github.com/dalemyers/DictionaryCoder/discussions)
- **Pull Requests**: Contributions are welcome!
