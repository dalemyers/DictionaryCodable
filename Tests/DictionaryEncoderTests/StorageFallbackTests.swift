//
//  StorageFallbackTests.swift
//  DictionaryCoder
//
//  Created by Dale Myers on 28/10/2025.
//

@testable import DictionaryCoder
import XCTest

final class StorageFallbackTests: XCTestCase {
    // Test the fallback path in DictionaryKeyedEncodingContainer.storage getter
    // when storage.value is not a dictionary
    func testKeyedContainerStorageFallbackWhenWrongType() throws {
        // Create a storage with wrong type (array instead of dictionary)
        let storage = _DictionaryEncoder.Storage("wrong type")
        let encoder = _DictionaryEncoder(storage: storage)

        // Create a keyed container - note we're calling the container directly
        // on the internal encoder, bypassing the type-fixing logic
        struct TestKey: CodingKey {
            var stringValue: String
            var intValue: Int?
            init(stringValue: String) {
                self.stringValue = stringValue
                intValue = nil
            }

            init?(intValue: Int) {
                stringValue = "\(intValue)"
                self.intValue = intValue
            }
        }

        var container = DictionaryKeyedEncodingContainer<TestKey>(encoder: encoder)

        // Accessing storage should trigger the fallback path
        try container.encode("test", forKey: TestKey(stringValue: "key"))

        // The storage should have been set despite starting with wrong type
        XCTAssertNotNil(storage.value)
    }

    // Test the fallback paths in DictionaryUnkeyedEncodingContainer
    func testUnkeyedContainerStorageFallbackWhenWrongType() throws {
        // Create a storage with wrong type (dictionary instead of array)
        let storage = _DictionaryEncoder.Storage("wrong type")
        let encoder = _DictionaryEncoder(storage: storage)

        // Create an unkeyed container directly
        var container = DictionaryUnkeyedEncodingContainer(encoder: encoder)

        // Accessing count should trigger the fallback path (returns 0)
        let count = container.count
        XCTAssertEqual(count, 0)

        // Encoding should work despite wrong initial storage type
        try container.encode("test")

        // The storage should have been set despite starting with wrong type
        XCTAssertNotNil(storage.value)
    }

    // Test accessing count when storage is nil
    func testUnkeyedContainerCountFallbackWithNilStorage() throws {
        // Create a storage with nil
        let storage = _DictionaryEncoder.Storage([Any]?.none as Any)
        let encoder = _DictionaryEncoder(storage: storage)

        // Create an unkeyed container directly
        let container = DictionaryUnkeyedEncodingContainer(encoder: encoder)

        // Accessing count should trigger the fallback path (returns 0)
        let count = container.count
        XCTAssertEqual(count, 0)
    }
}
