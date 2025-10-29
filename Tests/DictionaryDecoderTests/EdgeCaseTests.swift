@testable import DictionaryCoder
import Foundation
import Testing

// MARK: - Edge Cases and Advanced Features

@Test func emptyDictionary() throws {
    struct EmptyModel: Codable {}

    let decoder = DictionaryCoder()
    let dict: [String: Any] = [:]

    _ = try decoder.decode(EmptyModel.self, from: dict)
}

@Test func emptyArray() throws {
    struct ArrayModel: Codable {
        let items: [String]
        let numbers: [Int]
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = [
        "items": [],
        "numbers": [],
    ]

    let result = try decoder.decode(ArrayModel.self, from: dict)
    #expect(result.items.isEmpty)
    #expect(result.numbers.isEmpty)
}

@Test func mixedTypes() throws {
    struct SimpleModel: Codable {
        let name: String
        let age: Int
        let isActive: Bool
    }

    struct MixedTypesModel: Codable {
        let text: String
        let number: Int
        let flag: Bool
        let nested: SimpleModel
        let array: [Int]
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = [
        "text": "Hello",
        "number": 42,
        "flag": true,
        "nested": [
            "name": "Nested",
            "age": 25,
            "isActive": false,
        ],
        "array": [1, 2, 3],
    ]

    let result = try decoder.decode(MixedTypesModel.self, from: dict)
    #expect(result.text == "Hello")
    #expect(result.number == 42)
    #expect(result.flag == true)
    #expect(result.nested.name == "Nested")
    #expect(result.array == [1, 2, 3])
}

@Test func testUserInfo() throws {
    struct TestModel: Decodable {
        let customValue: String

        init(from decoder: Decoder) throws {
            guard let custom = decoder.userInfo[CodingUserInfoKey(rawValue: "customKey")!] as? String else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Missing user info"))
            }
            customValue = custom
        }
    }

    let decoder = DictionaryCoder()
    decoder.userInfo[CodingUserInfoKey(rawValue: "customKey")!] = "customValue"

    let dict: [String: Any] = [:]
    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.customValue == "customValue")
}
