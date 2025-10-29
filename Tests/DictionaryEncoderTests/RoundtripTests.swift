//
//  RoundtripTests.swift
//  DictionaryCoder
//
//  Created by Dale Myers on 28/10/2025.
//

@testable import DictionaryCoder
import XCTest

final class RoundtripTests: XCTestCase {
    func testRoundtripSimpleStruct() throws {
        struct Person: Codable, Equatable {
            let name: String
            let age: Int
        }

        let original = Person(name: "Alice", age: 30)

        let encoder = DictionaryEncoder()
        let dict = try encoder.encode(original)

        let decoder = DictionaryCoder()
        let decoded = try decoder.decode(Person.self, from: dict)

        XCTAssertEqual(original, decoded)
    }

    func testRoundtripAllPrimitiveTypes() throws {
        struct AllTypes: Codable, Equatable {
            let string: String
            let int: Int
            let double: Double
            let float: Float
            let bool: Bool
            let int8: Int8
            let int16: Int16
            let int32: Int32
            let int64: Int64
            let uint: UInt
            let uint8: UInt8
            let uint16: UInt16
            let uint32: UInt32
            let uint64: UInt64
        }

        let original = AllTypes(
            string: "test",
            int: 42,
            double: 3.14,
            float: 2.71,
            bool: true,
            int8: -128,
            int16: -32768,
            int32: -2_147_483_648,
            int64: -9_223_372_036_854_775_808,
            uint: 42,
            uint8: 255,
            uint16: 65535,
            uint32: 4_294_967_295,
            uint64: 18_446_744_073_709_551_615
        )

        let encoder = DictionaryEncoder()
        let dict = try encoder.encode(original)

        let decoder = DictionaryCoder()
        let decoded = try decoder.decode(AllTypes.self, from: dict)

        XCTAssertEqual(original, decoded)
    }

    func testRoundtripOptionalValues() throws {
        struct OptionalFields: Codable, Equatable {
            let required: String
            let optional: String?
            let nilValue: Int?
        }

        let original = OptionalFields(required: "present", optional: "also present", nilValue: nil)

        let encoder = DictionaryEncoder()
        let dict = try encoder.encode(original)

        let decoder = DictionaryCoder()
        let decoded = try decoder.decode(OptionalFields.self, from: dict)

        XCTAssertEqual(original, decoded)
    }

    func testRoundtripNestedStruct() throws {
        struct Address: Codable, Equatable {
            let street: String
            let city: String
        }

        struct Person: Codable, Equatable {
            let name: String
            let address: Address
        }

        let original = Person(
            name: "Bob",
            address: Address(street: "123 Main St", city: "Springfield")
        )

        let encoder = DictionaryEncoder()
        let dict = try encoder.encode(original)

        let decoder = DictionaryCoder()
        let decoded = try decoder.decode(Person.self, from: dict)

        XCTAssertEqual(original, decoded)
    }

    func testRoundtripDeeplyNestedStructs() throws {
        struct Level3: Codable, Equatable {
            let value: String
        }

        struct Level2: Codable, Equatable {
            let level3: Level3
        }

        struct Level1: Codable, Equatable {
            let level2: Level2
        }

        let original = Level1(level2: Level2(level3: Level3(value: "deep")))

        let encoder = DictionaryEncoder()
        let dict = try encoder.encode(original)

        let decoder = DictionaryCoder()
        let decoded = try decoder.decode(Level1.self, from: dict)

        XCTAssertEqual(original, decoded)
    }

    func testRoundtripArrayOfPrimitives() throws {
        struct Container: Codable, Equatable {
            let numbers: [Int]
        }

        let original = Container(numbers: [1, 2, 3, 4, 5])

        let encoder = DictionaryEncoder()
        let dict = try encoder.encode(original)

        let decoder = DictionaryCoder()
        let decoded = try decoder.decode(Container.self, from: dict)

        XCTAssertEqual(original, decoded)
    }

    func testRoundtripArrayOfStructs() throws {
        struct Item: Codable, Equatable {
            let id: Int
            let name: String
        }

        struct Container: Codable, Equatable {
            let items: [Item]
        }

        let original = Container(items: [
            Item(id: 1, name: "first"),
            Item(id: 2, name: "second"),
        ])

        let encoder = DictionaryEncoder()
        let dict = try encoder.encode(original)

        let decoder = DictionaryCoder()
        let decoded = try decoder.decode(Container.self, from: dict)

        XCTAssertEqual(original, decoded)
    }

    func testRoundtripEmptyArray() throws {
        struct Container: Codable, Equatable {
            let empty: [String]
        }

        let original = Container(empty: [])

        let encoder = DictionaryEncoder()
        let dict = try encoder.encode(original)

        let decoder = DictionaryCoder()
        let decoded = try decoder.decode(Container.self, from: dict)

        XCTAssertEqual(original, decoded)
    }

    func testRoundtripStringEnum() throws {
        enum Status: String, Codable {
            case active
            case inactive
        }

        struct Record: Codable, Equatable {
            let status: Status
        }

        let original = Record(status: .active)

        let encoder = DictionaryEncoder()
        let dict = try encoder.encode(original)

        let decoder = DictionaryCoder()
        let decoded = try decoder.decode(Record.self, from: dict)

        XCTAssertEqual(original, decoded)
    }

    func testRoundtripIntEnum() throws {
        enum Priority: Int, Codable {
            case low = 1
            case medium = 2
            case high = 3
        }

        struct Task: Codable, Equatable {
            let priority: Priority
        }

        let original = Task(priority: .high)

        let encoder = DictionaryEncoder()
        let dict = try encoder.encode(original)

        let decoder = DictionaryCoder()
        let decoded = try decoder.decode(Task.self, from: dict)

        XCTAssertEqual(original, decoded)
    }

    func testRoundtripNestedArrays() throws {
        struct Container: Codable, Equatable {
            let matrix: [[Int]]
        }

        let original = Container(matrix: [[1, 2], [3, 4], [5, 6]])

        let encoder = DictionaryEncoder()
        let dict = try encoder.encode(original)

        let decoder = DictionaryCoder()
        let decoded = try decoder.decode(Container.self, from: dict)

        XCTAssertEqual(original, decoded)
    }

    func testRoundtripMixedNestedContainers() throws {
        struct Inner: Codable, Equatable {
            let values: [Int]
        }

        struct Outer: Codable, Equatable {
            let name: String
            let inners: [Inner]
        }

        let original = Outer(
            name: "test",
            inners: [
                Inner(values: [1, 2, 3]),
                Inner(values: [4, 5, 6]),
            ]
        )

        let encoder = DictionaryEncoder()
        let dict = try encoder.encode(original)

        let decoder = DictionaryCoder()
        let decoded = try decoder.decode(Outer.self, from: dict)

        XCTAssertEqual(original, decoded)
    }

    func testRoundtripComplexRealWorld() throws {
        struct Contact: Codable, Equatable {
            let email: String
            let phone: String?
        }

        struct Address: Codable, Equatable {
            let street: String
            let city: String
            let zipCode: String
        }

        struct Company: Codable, Equatable {
            let name: String
            let employees: Int
        }

        struct Person: Codable, Equatable {
            let id: Int
            let name: String
            let age: Int
            let isActive: Bool
            let contact: Contact
            let addresses: [Address]
            let company: Company?
            let tags: [String]
        }

        let original = Person(
            id: 123,
            name: "John Doe",
            age: 35,
            isActive: true,
            contact: Contact(email: "john@example.com", phone: "555-1234"),
            addresses: [
                Address(street: "123 Main St", city: "Springfield", zipCode: "12345"),
                Address(street: "456 Oak Ave", city: "Shelbyville", zipCode: "67890"),
            ],
            company: Company(name: "Acme Corp", employees: 500),
            tags: ["developer", "swift", "ios"]
        )

        let encoder = DictionaryEncoder()
        let dict = try encoder.encode(original)

        let decoder = DictionaryCoder()
        let decoded = try decoder.decode(Person.self, from: dict)

        XCTAssertEqual(original, decoded)
    }
}
