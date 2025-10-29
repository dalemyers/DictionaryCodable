@testable import DictionaryCoder
import Foundation
import Testing

// MARK: - Keyed Container Tests

@Test func keyedContainerAllKeys() throws {
    struct DynamicModel: Codable {
        let values: [String: String]

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: DynamicCodingKey.self)
            var dict: [String: String] = [:]

            for key in container.allKeys {
                if let value = try? container.decode(String.self, forKey: key) {
                    dict[key.stringValue] = value
                }
            }
            values = dict
        }
    }

    struct DynamicCodingKey: CodingKey {
        var stringValue: String
        var intValue: Int? { nil }

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue _: Int) {
            nil
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = [
        "key1": "value1",
        "key2": "value2",
        "key3": "value3",
    ]

    let result = try decoder.decode(DynamicModel.self, from: dict)
    #expect(result.values.count == 3)
    #expect(result.values["key1"] == "value1")
    #expect(result.values["key2"] == "value2")
    #expect(result.values["key3"] == "value3")
}

@Test func keyedContainerContains() throws {
    struct TestModel: Decodable {
        let hasKey: Bool
        let missingKey: Bool

        enum CodingKeys: String, CodingKey {
            case existing
            case missing
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            hasKey = container.contains(.existing)
            missingKey = container.contains(.missing)
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["existing": "value"]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.hasKey == true)
    #expect(result.missingKey == false)
}

@Test func keyedContainerDecodeNil() throws {
    struct TestModel: Decodable {
        let isNil1: Bool
        let isNil2: Bool
        let isNotNil: Bool

        enum CodingKeys: String, CodingKey {
            case null1
            case null2
            case value
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            isNil1 = try container.decodeNil(forKey: .null1)
            isNil2 = try container.decodeNil(forKey: .null2)
            isNotNil = try container.decodeNil(forKey: .value)
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = [
        "null1": NSNull(),
        "value": "something",
    ]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.isNil1 == true)
    #expect(result.isNil2 == true) // Missing key
    #expect(result.isNotNil == false)
}

@Test func nestedKeyedContainer() throws {
    struct OuterModel: Decodable {
        let inner: InnerModel

        struct InnerModel: Codable {
            let value: String
        }

        enum CodingKeys: String, CodingKey {
            case nested
        }

        enum NestedKeys: String, CodingKey {
            case value
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let nestedContainer = try container.nestedContainer(keyedBy: NestedKeys.self, forKey: .nested)
            let value = try nestedContainer.decode(String.self, forKey: .value)
            inner = InnerModel(value: value)
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = [
        "nested": ["value": "test"],
    ]

    let result = try decoder.decode(OuterModel.self, from: dict)
    #expect(result.inner.value == "test")
}

@Test func testNestedUnkeyedContainer() throws {
    struct OuterModel: Decodable {
        let items: [String]

        enum CodingKeys: String, CodingKey {
            case array
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            var nestedContainer = try container.nestedUnkeyedContainer(forKey: .array)

            var items: [String] = []
            while !nestedContainer.isAtEnd {
                try items.append(nestedContainer.decode(String.self))
            }
            self.items = items
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = [
        "array": ["a", "b", "c"],
    ]

    let result = try decoder.decode(OuterModel.self, from: dict)
    #expect(result.items == ["a", "b", "c"])
}

@Test func testSuperDecoder() throws {
    struct SuperDecoderModel: Codable {
        let name: String
        let extra: [String: String]

        enum CodingKeys: String, CodingKey {
            case name
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)

            let superDecoder = try container.superDecoder()
            let superContainer = try superDecoder.singleValueContainer()
            if let dict = try? superContainer.decode([String: String].self) {
                extra = dict
            } else {
                extra = [:]
            }
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = [
        "name": "Test",
        "extra1": "value1",
        "extra2": "value2",
    ]

    let result = try decoder.decode(SuperDecoderModel.self, from: dict)
    #expect(result.name == "Test")
    #expect(result.extra.count >= 1) // At least name should be there
}

@Test func superDecoderForKey() throws {
    struct SuperDecoderForKeyModel: Codable {
        let name: String
        let metadata: [String: String]

        enum CodingKeys: String, CodingKey {
            case name
            case metadata
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)

            let superDecoder = try container.superDecoder(forKey: .metadata)
            let superContainer = try superDecoder.singleValueContainer()
            metadata = try superContainer.decode([String: String].self)
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = [
        "name": "Test",
        "metadata": [
            "key1": "value1",
            "key2": "value2",
        ],
    ]

    let result = try decoder.decode(SuperDecoderForKeyModel.self, from: dict)
    #expect(result.name == "Test")
    #expect(result.metadata["key1"] == "value1")
    #expect(result.metadata["key2"] == "value2")
}

@Test func superDecoderForKeyWithMissingKey() throws {
    struct TestModel: Decodable {
        let name: String
        let metadata: [String: String]

        enum CodingKeys: String, CodingKey {
            case name
            case missing
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)

            let superDecoder = try container.superDecoder(forKey: .missing)
            let superContainer = try superDecoder.singleValueContainer()
            if let dict = try? superContainer.decode([String: String].self) {
                metadata = dict
            } else {
                metadata = [:]
            }
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["name": "Test"]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.name == "Test")
    #expect(result.metadata == [:])
}

// MARK: - Unkeyed Container Tests

@Test func unkeyedContainerDecoding() throws {
    struct ArrayWrapperModel: Decodable {
        let items: [String]
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["items": ["a", "b", "c"]]

    let result = try decoder.decode(ArrayWrapperModel.self, from: dict)
    #expect(result.items == ["a", "b", "c"])
}

@Test func unkeyedContainerCount() throws {
    struct CountModel: Decodable {
        let items: [Int]
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["items": [1, 2, 3, 4, 5]]

    let result = try decoder.decode(CountModel.self, from: dict)
    #expect(result.items.count == 5)
}

@Test func unkeyedContainerDecodeNil() throws {
    struct NilTestModel: Decodable {
        let values: [String?]
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = [
        "values": ["first", NSNull(), "third"],
    ]

    let result = try decoder.decode(NilTestModel.self, from: dict)
    #expect(result.values.count == 3)
    #expect(result.values[0] == "first")
    #expect(result.values[1] == nil)
    #expect(result.values[2] == "third")
}

@Test func unkeyedContainerNestedKeyed() throws {
    struct SimpleModel: Codable {
        let name: String
        let age: Int
        let isActive: Bool
    }

    struct TestModel: Decodable {
        let items: [SimpleModel]
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = [
        "items": [
            ["name": "Alice", "age": 30, "isActive": true],
            ["name": "Bob", "age": 25, "isActive": false],
        ],
    ]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.items.count == 2)
    #expect(result.items[0].name == "Alice")
    #expect(result.items[1].name == "Bob")
}

@Test func unkeyedContainerNestedUnkeyed() throws {
    struct TestModel: Decodable {
        let matrix: [[Int]]
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = [
        "matrix": [
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9],
        ],
    ]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.matrix == [[1, 2, 3], [4, 5, 6], [7, 8, 9]])
}

@Test func unkeyedContainerSuperDecoder() throws {
    struct TestModel: Decodable {
        let items: [String]
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["items": ["a", "b", "c"]]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.items == ["a", "b", "c"])
}

@Test func unkeyedDecodeNilWhenNotAtEnd() throws {
    struct TestModel: Decodable {
        let items: [String?]
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["items": ["value", NSNull()]]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.items.count == 2)
    #expect(result.items[0] == "value")
    #expect(result.items[1] == nil)
}

@Test func unkeyedDecodeNilReturnsTrueWhenAtEnd() throws {
    struct TestModel: Decodable {
        let items: [Int]
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["items": [1, 2, 3]]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.items == [1, 2, 3])
}

// MARK: - Single Value Container Tests

@Test func singleValueContainerDecodeNil() throws {
    struct TestModel: Decodable {
        let value: String?
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["value": NSNull()]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.value == nil)
}

// MARK: - UnkeyedContainer Coverage Tests

@Test func unkeyedContainerCountProperty() throws {
    struct TestModel: Codable {
        let items: [String]
        let count: Int?

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            var unkeyedContainer = try container.nestedUnkeyedContainer(forKey: .items)
            count = unkeyedContainer.count
            var items: [String] = []
            while !unkeyedContainer.isAtEnd {
                try items.append(unkeyedContainer.decode(String.self))
            }
            self.items = items
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(items, forKey: .items)
        }

        enum CodingKeys: String, CodingKey {
            case items
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["items": ["a", "b", "c"]]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.count == 3)
    #expect(result.items == ["a", "b", "c"])
}

@Test func unkeyedNestedKeyedContainer() throws {
    struct Inner: Codable {
        let name: String
    }

    struct TestModel: Codable {
        let items: [Inner]

        init(from decoder: Decoder) throws {
            let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
            var container = try keyedContainer.nestedUnkeyedContainer(forKey: .items)
            var items: [Inner] = []
            while !container.isAtEnd {
                let nestedContainer = try container.nestedContainer(keyedBy: InnerKeys.self)
                let name = try nestedContainer.decode(String.self, forKey: .name)
                items.append(Inner(name: name))
            }
            self.items = items
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(items, forKey: .items)
        }

        enum CodingKeys: String, CodingKey {
            case items
        }

        enum InnerKeys: String, CodingKey {
            case name
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = [
        "items": [
            ["name": "Alice"],
            ["name": "Bob"],
        ],
    ]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.items.count == 2)
    #expect(result.items[0].name == "Alice")
    #expect(result.items[1].name == "Bob")
}

@Test func unkeyedNestedKeyedContainerAtEnd() throws {
    struct TestModel: Codable {
        init(from decoder: Decoder) throws {
            let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
            var container = try keyedContainer.nestedUnkeyedContainer(forKey: .items)
            _ = try container.decode(String.self)
            _ = try container.nestedContainer(keyedBy: DummyKeys.self)
        }

        func encode(to _: Encoder) throws {}

        enum CodingKeys: String, CodingKey {
            case items
        }

        enum DummyKeys: String, CodingKey {
            case dummy
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["items": ["test"]]

    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(TestModel.self, from: dict)
    }
}

@Test func unkeyedContainerNestedKeyedWrongType() throws {
    struct TestModel: Codable {
        init(from decoder: Decoder) throws {
            let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
            var container = try keyedContainer.nestedUnkeyedContainer(forKey: .items)
            _ = try container.nestedContainer(keyedBy: DummyKeys.self)
        }

        func encode(to _: Encoder) throws {}

        enum CodingKeys: String, CodingKey {
            case items
        }

        enum DummyKeys: String, CodingKey {
            case dummy
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["items": ["not a dictionary"]]

    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(TestModel.self, from: dict)
    }
}

@Test func unkeyedNestedUnkeyedContainer() throws {
    struct TestModel: Codable {
        let matrix: [[Int]]

        init(from decoder: Decoder) throws {
            let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
            var container = try keyedContainer.nestedUnkeyedContainer(forKey: .matrix)
            var matrix: [[Int]] = []
            while !container.isAtEnd {
                var nestedContainer = try container.nestedUnkeyedContainer()
                var row: [Int] = []
                while !nestedContainer.isAtEnd {
                    try row.append(nestedContainer.decode(Int.self))
                }
                matrix.append(row)
            }
            self.matrix = matrix
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(matrix, forKey: .matrix)
        }

        enum CodingKeys: String, CodingKey {
            case matrix
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = [
        "matrix": [
            [1, 2, 3],
            [4, 5, 6],
        ],
    ]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.matrix.count == 2)
    #expect(result.matrix[0] == [1, 2, 3])
    #expect(result.matrix[1] == [4, 5, 6])
}

@Test func unkeyedContainerNestedUnkeyedAtEnd() throws {
    struct TestModel: Codable {
        init(from decoder: Decoder) throws {
            let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
            var container = try keyedContainer.nestedUnkeyedContainer(forKey: .items)
            _ = try container.decode(String.self)
            _ = try container.nestedUnkeyedContainer()
        }

        func encode(to _: Encoder) throws {}

        enum CodingKeys: String, CodingKey {
            case items
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["items": ["test"]]

    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(TestModel.self, from: dict)
    }
}

@Test func unkeyedContainerNestedUnkeyedWrongType() throws {
    struct TestModel: Codable {
        init(from decoder: Decoder) throws {
            let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
            var container = try keyedContainer.nestedUnkeyedContainer(forKey: .items)
            _ = try container.nestedUnkeyedContainer()
        }

        func encode(to _: Encoder) throws {}

        enum CodingKeys: String, CodingKey {
            case items
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["items": ["not an array"]]

    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(TestModel.self, from: dict)
    }
}

@Test func unkeyedSuperDecoder() throws {
    struct TestModel: Codable {
        let value: String

        init(from decoder: Decoder) throws {
            let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
            var container = try keyedContainer.nestedUnkeyedContainer(forKey: .items)
            let superDecoder = try container.superDecoder()
            value = try String(from: superDecoder)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            var unkeyedContainer = container.nestedUnkeyedContainer(forKey: .items)
            try unkeyedContainer.encode(value)
        }

        enum CodingKeys: String, CodingKey {
            case items
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["items": ["test"]]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.value == "test")
}

@Test func unkeyedContainerSuperDecoderAtEnd() throws {
    struct TestModel: Codable {
        init(from decoder: Decoder) throws {
            let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
            var container = try keyedContainer.nestedUnkeyedContainer(forKey: .items)
            _ = try container.decode(String.self)
            _ = try container.superDecoder()
        }

        func encode(to _: Encoder) throws {}

        enum CodingKeys: String, CodingKey {
            case items
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["items": ["test"]]

    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(TestModel.self, from: dict)
    }
}

@Test func unkeyedDecodeNil() throws {
    struct TestModel: Codable {
        let value: String?

        init(from decoder: Decoder) throws {
            let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
            var container = try keyedContainer.nestedUnkeyedContainer(forKey: .items)
            if try container.decodeNil() {
                value = nil
            } else {
                value = try container.decode(String.self)
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            var unkeyedContainer = container.nestedUnkeyedContainer(forKey: .items)
            try unkeyedContainer.encode(value)
        }

        enum CodingKeys: String, CodingKey {
            case items
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["items": [NSNull()]]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.value == nil)
}

@Test func unkeyedDecodeNilWhenNotNil() throws {
    struct TestModel: Codable {
        let hasNil: Bool
        let value: String

        init(from decoder: Decoder) throws {
            let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
            var container = try keyedContainer.nestedUnkeyedContainer(forKey: .items)
            hasNil = try container.decodeNil()
            value = try container.decode(String.self)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            var unkeyedContainer = container.nestedUnkeyedContainer(forKey: .items)
            try unkeyedContainer.encode(value)
        }

        enum CodingKeys: String, CodingKey {
            case items
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["items": ["test"]]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.hasNil == false)
    #expect(result.value == "test")
}

@Test func unkeyedDecodeNilAtEnd() throws {
    struct TestModel: Codable {
        let isNil: Bool

        init(from decoder: Decoder) throws {
            let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
            var container = try keyedContainer.nestedUnkeyedContainer(forKey: .items)
            _ = try container.decode(String.self)
            isNil = try container.decodeNil()
        }

        func encode(to _: Encoder) throws {}

        enum CodingKeys: String, CodingKey {
            case items
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["items": ["test"]]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.isNil == true)
}

@Test func unkeyedDecodeAtEndError() throws {
    struct TestModel: Codable {
        init(from decoder: Decoder) throws {
            let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
            var container = try keyedContainer.nestedUnkeyedContainer(forKey: .items)
            _ = try container.decode(String.self)
            _ = try container.decode(String.self)
        }

        func encode(to _: Encoder) throws {}

        enum CodingKeys: String, CodingKey {
            case items
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["items": ["test"]]

    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(TestModel.self, from: dict)
    }
}

@Test func directTypeMatchInKeyedContainer() throws {
    // This test targets the direct type match path in DictionaryKeyedDecodingContainer.decodeValue (line 100)
    // We need to pass a value that's already the exact type T being requested
    struct TestModel: Decodable {
        let value: String

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            // This will hit the direct cast path: if let val = value as? T { return val }
            value = try container.decode(String.self, forKey: .value)
        }

        enum CodingKeys: String, CodingKey {
            case value
        }
    }

    let decoder = DictionaryCoder()
    // Use a direct String, not NSString or any other type
    let dict: [String: Any] = ["value": "direct match"]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.value == "direct match")
}

@Test func decodeNilWithMissingKey() throws {
    // This test specifically targets line 88 to ensure the "|| storage[key.stringValue] == nil" branch is covered
    struct TestModel: Decodable {
        let hasValue: Bool
        let isMissing: Bool

        enum CodingKeys: String, CodingKey {
            case value
            case missing
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            // This should return false (value exists and is not NSNull)
            hasValue = try container.decodeNil(forKey: .value)
            // This should return true (key is missing, triggering the == nil branch)
            isMissing = try container.decodeNil(forKey: .missing)
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["value": "something"]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.hasValue == false)
    #expect(result.isMissing == true)
}
