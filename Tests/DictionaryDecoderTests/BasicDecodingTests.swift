@testable import DictionaryCoder
import Foundation
import Testing

// MARK: - Basic Decoding Tests

@Test func simpleDecoding() throws {
    struct SimpleModel: Codable, Equatable {
        let name: String
        let age: Int
        let isActive: Bool
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = [
        "name": "John Doe",
        "age": 30,
        "isActive": true,
    ]

    let result = try decoder.decode(SimpleModel.self, from: dict)
    #expect(result.name == "John Doe")
    #expect(result.age == 30)
    #expect(result.isActive == true)
}

@Test func optionalValues() throws {
    struct OptionalModel: Codable, Equatable {
        let required: String
        let optional: String?
        let optionalInt: Int?
    }

    let decoder = DictionaryCoder()

    // Test with all values present
    let dict1: [String: Any] = [
        "required": "Hello",
        "optional": "World",
        "optionalInt": 42,
    ]
    let result1 = try decoder.decode(OptionalModel.self, from: dict1)
    #expect(result1.required == "Hello")
    #expect(result1.optional == "World")
    #expect(result1.optionalInt == 42)

    // Test with optional values missing
    let dict2: [String: Any] = [
        "required": "Hello",
    ]
    let result2 = try decoder.decode(OptionalModel.self, from: dict2)
    #expect(result2.required == "Hello")
    #expect(result2.optional == nil)
    #expect(result2.optionalInt == nil)

    // Test with NSNull
    let dict3: [String: Any] = [
        "required": "Hello",
        "optional": NSNull(),
        "optionalInt": NSNull(),
    ]
    let result3 = try decoder.decode(OptionalModel.self, from: dict3)
    #expect(result3.required == "Hello")
    #expect(result3.optional == nil)
    #expect(result3.optionalInt == nil)
}

@Test func nestedDictionaries() throws {
    struct SimpleModel: Codable, Equatable {
        let name: String
        let age: Int
        let isActive: Bool
    }

    struct NestedModel: Codable, Equatable {
        let simple: SimpleModel
        let name: String
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = [
        "name": "Parent",
        "simple": [
            "name": "Child",
            "age": 25,
            "isActive": false,
        ],
    ]

    let result = try decoder.decode(NestedModel.self, from: dict)
    #expect(result.name == "Parent")
    #expect(result.simple.name == "Child")
    #expect(result.simple.age == 25)
    #expect(result.simple.isActive == false)
}

@Test func arrayDecoding() throws {
    struct ArrayModel: Codable, Equatable {
        let items: [String]
        let numbers: [Int]
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = [
        "items": ["apple", "banana", "cherry"],
        "numbers": [1, 2, 3, 4, 5],
    ]

    let result = try decoder.decode(ArrayModel.self, from: dict)
    #expect(result.items == ["apple", "banana", "cherry"])
    #expect(result.numbers == [1, 2, 3, 4, 5])
}

@Test func complexArrayDecoding() throws {
    struct SimpleModel: Codable, Equatable {
        let name: String
        let age: Int
        let isActive: Bool
    }

    struct ComplexArrayModel: Codable, Equatable {
        let people: [SimpleModel]
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = [
        "people": [
            ["name": "Alice", "age": 30, "isActive": true],
            ["name": "Bob", "age": 25, "isActive": false],
            ["name": "Charlie", "age": 35, "isActive": true],
        ],
    ]

    let result = try decoder.decode(ComplexArrayModel.self, from: dict)
    #expect(result.people.count == 3)
    #expect(result.people[0].name == "Alice")
    #expect(result.people[1].name == "Bob")
    #expect(result.people[2].name == "Charlie")
}

@Test func directTypeMatchInSingleValue() throws {
    struct TestModel: Decodable {
        let value: String
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["value": "Direct Match"]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.value == "Direct Match")
}
