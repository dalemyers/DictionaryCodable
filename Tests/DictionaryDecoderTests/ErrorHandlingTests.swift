@testable import DictionaryCoder
import Foundation
import Testing

// MARK: - Error Tests

@Test func missingKeyError() throws {
    struct SimpleModel: Codable {
        let name: String
        let age: Int
        let isActive: Bool
    }

    let decoder = DictionaryDecoder()
    let dict: [String: Any] = [
        "name": "Test",
        "age": 30,
        // missing "isActive"
    ]

    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(SimpleModel.self, from: dict)
    }
}

@Test func typeMismatchError() throws {
    struct SimpleModel: Codable {
        let name: String
        let age: Int
        let isActive: Bool
    }

    let decoder = DictionaryDecoder()
    let dict: [String: Any] = [
        "name": "Test",
        "age": "not a number", // Wrong type
        "isActive": true,
    ]

    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(SimpleModel.self, from: dict)
    }
}

@Test func invalidContainerTypeForKeyed() throws {
    struct TestModel: Decodable {
        init(from decoder: Decoder) throws {
            _ = try decoder.container(keyedBy: CodingKeys.self)
        }

        enum CodingKeys: String, CodingKey {
            case test
        }
    }

    #expect(throws: DecodingError.self) {
        let internalDecoder = _DictionaryDecoder(storage: [1, 2, 3])
        _ = try internalDecoder.container(keyedBy: TestModel.CodingKeys.self)
    }
}

@Test func invalidContainerTypeForUnkeyed() throws {
    let decoder = _DictionaryDecoder(storage: ["key": "value"])

    #expect(throws: DecodingError.self) {
        _ = try decoder.unkeyedContainer()
    }
}

@Test func nestedKeyedContainerMissingKey() throws {
    struct TestModel: Decodable {
        enum CodingKeys: String, CodingKey {
            case missing
        }

        enum NestedKeys: String, CodingKey {
            case value
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            _ = try container.nestedContainer(keyedBy: NestedKeys.self, forKey: .missing)
        }
    }

    let decoder = DictionaryDecoder()
    let dict: [String: Any] = ["other": "value"]

    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(TestModel.self, from: dict)
    }
}

@Test func nestedKeyedContainerWrongType() throws {
    struct TestModel: Decodable {
        enum CodingKeys: String, CodingKey {
            case wrongType
        }

        enum NestedKeys: String, CodingKey {
            case value
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            _ = try container.nestedContainer(keyedBy: NestedKeys.self, forKey: .wrongType)
        }
    }

    let decoder = DictionaryDecoder()
    let dict: [String: Any] = ["wrongType": "not a dict"]

    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(TestModel.self, from: dict)
    }
}

@Test func nestedUnkeyedContainerMissingKey() throws {
    struct TestModel: Decodable {
        enum CodingKeys: String, CodingKey {
            case missing
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            _ = try container.nestedUnkeyedContainer(forKey: .missing)
        }
    }

    let decoder = DictionaryDecoder()
    let dict: [String: Any] = ["other": "value"]

    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(TestModel.self, from: dict)
    }
}

@Test func nestedUnkeyedContainerWrongType() throws {
    struct TestModel: Decodable {
        enum CodingKeys: String, CodingKey {
            case wrongType
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            _ = try container.nestedUnkeyedContainer(forKey: .wrongType)
        }
    }

    let decoder = DictionaryDecoder()
    let dict: [String: Any] = ["wrongType": "not an array"]

    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(TestModel.self, from: dict)
    }
}

@Test func unkeyedNestedKeyedAtEnd() throws {
    struct TestModel: Decodable {
        init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            // Read all items
            while !container.isAtEnd {
                _ = try container.decode(Int.self)
            }
            // Try to get nested container when at end
            _ = try container.nestedContainer(keyedBy: CodingKeys.self)
        }

        enum CodingKeys: String, CodingKey {
            case test
        }
    }

    let decoder = DictionaryDecoder()
    let dict: [String: Any] = ["test": [1, 2, 3]]

    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(TestModel.self, from: dict)
    }
}

@Test func unkeyedNestedUnkeyedAtEnd() throws {
    struct TestModel: Decodable {
        init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            // Read all items
            while !container.isAtEnd {
                _ = try container.decode(Int.self)
            }
            // Try to get nested container when at end
            _ = try container.nestedUnkeyedContainer()
        }
    }

    let decoder = DictionaryDecoder()
    let dict: [String: Any] = ["test": [1, 2, 3]]

    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(TestModel.self, from: dict)
    }
}

@Test func unkeyedSuperDecoderAtEnd() throws {
    struct TestModel: Decodable {
        init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            // Read all items
            while !container.isAtEnd {
                _ = try container.decode(Int.self)
            }
            // Try to get super decoder when at end
            _ = try container.superDecoder()
        }
    }

    let decoder = DictionaryDecoder()
    let dict: [String: Any] = ["test": [1, 2, 3]]

    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(TestModel.self, from: dict)
    }
}

@Test func unkeyedDecodeAtEnd() throws {
    struct TestModel: Decodable {
        init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            // Read all items
            while !container.isAtEnd {
                _ = try container.decode(Int.self)
            }
            // Try to decode when at end
            _ = try container.decode(Int.self)
        }
    }

    let decoder = DictionaryDecoder()
    let dict: [String: Any] = ["test": [1, 2, 3]]

    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(TestModel.self, from: dict)
    }
}

@Test func unkeyedNestedKeyedWrongType() throws {
    struct TestModel: Decodable {
        enum NestedKeys: String, CodingKey {
            case value
        }

        init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            _ = try container.nestedContainer(keyedBy: NestedKeys.self)
        }
    }

    let decoder = DictionaryDecoder()
    let dict: [String: Any] = ["test": ["not a dict"]]

    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(TestModel.self, from: dict)
    }
}

@Test func unkeyedNestedUnkeyedWrongType() throws {
    struct TestModel: Decodable {
        init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            _ = try container.nestedUnkeyedContainer()
        }
    }

    let decoder = DictionaryDecoder()
    let dict: [String: Any] = ["test": ["not an array"]]

    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(TestModel.self, from: dict)
    }
}

@Test func singleValueTypeMismatch() throws {
    struct TestModel: Decodable {
        let value: Int

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            value = try container.decode(Int.self)
        }
    }

    let decoder = DictionaryDecoder()
    let dict: [String: Any] = ["value": "cannot convert to int"]

    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(TestModel.self, from: dict)
    }
}

@Test func valueNotFoundForNil() throws {
    struct TestModel: Decodable {
        let value: String

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            value = try container.decode(String.self)
        }
    }

    let decoder = DictionaryDecoder()
    let dict: [String: Any] = ["value": NSNull()]

    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(TestModel.self, from: dict)
    }
}

@Test func codingPathInErrors() throws {
    struct SimpleModel: Codable {
        let name: String
        let age: Int
        let isActive: Bool
    }

    struct NestedModel: Codable {
        let simple: SimpleModel
        let name: String
    }

    let decoder = DictionaryDecoder()
    let dict: [String: Any] = [
        "simple": [
            "name": "Test",
            "age": "invalid", // Wrong type
            "isActive": true,
        ],
        "name": "Parent",
    ]

    do {
        _ = try decoder.decode(NestedModel.self, from: dict)
        Issue.record("Expected decoding to throw")
    } catch let error as DecodingError {
        switch error {
        case let .typeMismatch(_, context):
            #expect(!context.codingPath.isEmpty)
        default:
            Issue.record("Wrong error type")
        }
    }
}

@Test func invalidStringToBoolConversion() throws {
    struct BoolModel: Codable {
        let value: Bool
    }

    let decoder = DictionaryDecoder()
    let dict: [String: Any] = ["value": "invalid"]

    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(BoolModel.self, from: dict)
    }
}

@Test func invalidStringToURLConversion() throws {
    struct URLModel: Codable {
        let url: URL
    }

    let decoder = DictionaryDecoder()
    // Invalid URL string (has spaces which are not valid in a URL without encoding)
    let dict: [String: Any] = ["url": "not a valid url with spaces"]

    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(URLModel.self, from: dict)
    }
}

@Test func invalidStringToDataConversion() throws {
    struct DataModel: Codable {
        let data: Data
    }

    let decoder = DictionaryDecoder()
    // Invalid base64 string
    let dict: [String: Any] = ["data": "not valid base64!!!"]

    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(DataModel.self, from: dict)
    }
}
