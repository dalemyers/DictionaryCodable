@testable import DictionaryCoder
import Foundation
import Testing

// MARK: - Numeric Conversion Tests

@Test func numericTypes() throws {
    struct NumericModel: Codable {
        let int8: Int8
        let int16: Int16
        let int32: Int32
        let int64: Int64
        let uint: UInt
        let uint8: UInt8
        let uint16: UInt16
        let uint32: UInt32
        let uint64: UInt64
        let double: Double
        let float: Float
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = [
        "int8": Int8(127),
        "int16": Int16(32767),
        "int32": Int32(2_147_483_647),
        "int64": Int64(9_223_372_036_854_775_807),
        "uint": UInt(100),
        "uint8": UInt8(255),
        "uint16": UInt16(65535),
        "uint32": UInt32(4_294_967_295),
        "uint64": UInt64(18_446_744_073_709_551_615),
        "double": 3.14159,
        "float": Float(2.718),
    ]

    let result = try decoder.decode(NumericModel.self, from: dict)
    #expect(result.int8 == 127)
    #expect(result.int16 == 32767)
    #expect(result.int32 == 2_147_483_647)
    #expect(result.int64 == 9_223_372_036_854_775_807)
    #expect(result.uint == 100)
    #expect(result.uint8 == 255)
    #expect(result.uint16 == 65535)
    #expect(result.uint32 == 4_294_967_295)
    #expect(result.uint64 == 18_446_744_073_709_551_615)
    #expect(result.double == 3.14159)
    #expect(result.float == Float(2.718))
}

@Test func numericConversionsFromNSNumber() throws {
    struct NumericModel: Codable {
        let int8: Int8
        let int16: Int16
        let int32: Int32
        let int64: Int64
        let uint: UInt
        let uint8: UInt8
        let uint16: UInt16
        let uint32: UInt32
        let uint64: UInt64
        let double: Double
        let float: Float
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = [
        "int8": NSNumber(value: 100),
        "int16": NSNumber(value: 1000),
        "int32": NSNumber(value: 100_000),
        "int64": NSNumber(value: 10_000_000),
        "uint": NSNumber(value: 50),
        "uint8": NSNumber(value: 200),
        "uint16": NSNumber(value: 50000),
        "uint32": NSNumber(value: 3_000_000_000),
        "uint64": NSNumber(value: 15_000_000_000),
        "double": NSNumber(value: 1.5),
        "float": NSNumber(value: 0.5),
    ]

    let result = try decoder.decode(NumericModel.self, from: dict)
    #expect(result.int8 == 100)
    #expect(result.int16 == 1000)
    #expect(result.int32 == 100_000)
    #expect(result.int64 == 10_000_000)
    #expect(result.uint == 50)
    #expect(result.uint8 == 200)
    #expect(result.uint16 == 50000)
    #expect(result.uint32 == 3_000_000_000)
    #expect(result.uint64 == 15_000_000_000)
    #expect(result.double == 1.5)
    #expect(result.float == 0.5)
}

@Test func numericConversionFromKeyedContainer() throws {
    struct TestModel: Decodable {
        let intFromNumber: Int
        let doubleFromNumber: Double
        let floatFromNumber: Float
        let boolFromNumber: Bool
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = [
        "intFromNumber": NSNumber(value: 42),
        "doubleFromNumber": NSNumber(value: 3.14),
        "floatFromNumber": NSNumber(value: 2.5),
        "boolFromNumber": NSNumber(value: true),
    ]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.intFromNumber == 42)
    #expect(result.doubleFromNumber == 3.14)
    #expect(result.floatFromNumber == 2.5)
    #expect(result.boolFromNumber == true)
}

@Test func stringToNumericConversion() throws {
    struct StringConversionModel: Codable {
        let stringInt: Int
        let stringDouble: Double
        let stringFloat: Float
        let stringBool: Bool
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = [
        "stringInt": "42",
        "stringDouble": "3.14",
        "stringFloat": "2.718",
        "stringBool": "true",
    ]

    let result = try decoder.decode(StringConversionModel.self, from: dict)
    #expect(result.stringInt == 42)
    #expect(result.stringDouble == 3.14)
    #expect(result.stringFloat == Float(2.718))
    #expect(result.stringBool == true)
}

@Test func stringToBoolConversions() throws {
    let decoder = DictionaryCoder()

    // Test true variations
    for trueValue in ["true", "1", "yes", "y", "TRUE", "Yes", " true ", " 1 "] {
        struct BoolModel: Codable {
            let value: Bool
        }
        let dict: [String: Any] = ["value": trueValue]
        let result = try decoder.decode(BoolModel.self, from: dict)
        #expect(result.value == true)
    }

    // Test false variations
    for falseValue in ["false", "0", "no", "n", "FALSE", "No", " false ", " 0 "] {
        struct BoolModel: Codable {
            let value: Bool
        }
        let dict: [String: Any] = ["value": falseValue]
        let result = try decoder.decode(BoolModel.self, from: dict)
        #expect(result.value == false)
    }
}

@Test func dataFromBase64String() throws {
    // Test that we can decode base64 strings to Data
    struct DataWrapperModel: Decodable {
        let data: Data

        enum CodingKeys: String, CodingKey {
            case data
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let singleContainer = try container.superDecoder(forKey: .data).singleValueContainer()

            // Decode the string and convert to Data
            if let str = try? singleContainer.decode(String.self),
               let decoded = Data(base64Encoded: str)
            {
                data = decoded
            } else {
                throw DecodingError.typeMismatch(
                    Data.self,
                    .init(codingPath: decoder.codingPath, debugDescription: "Could not decode Data from base64 string")
                )
            }
        }
    }

    let decoder = DictionaryCoder()
    let testString = "Hello, World!"
    let base64 = testString.data(using: .utf8)!.base64EncodedString()

    let dict: [String: Any] = ["data": base64]
    let result = try decoder.decode(DataWrapperModel.self, from: dict)

    let decodedString = String(data: result.data, encoding: .utf8)
    #expect(decodedString == testString)
}

@Test func dataFromDataBlob() throws {
    struct DataModel: Codable {
        let data: Data
    }

    let decoder = DictionaryCoder()
    let testData = "Test Data".data(using: .utf8)!

    let dict: [String: Any] = ["data": testData]
    let result = try decoder.decode(DataModel.self, from: dict)
    #expect(result.data == testData)
}

@Test func uRLFromString() throws {
    // Test URL conversion from string
    struct URLWrapperModel: Decodable {
        let url: URL

        enum CodingKeys: String, CodingKey {
            case url
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let singleContainer = try container.superDecoder(forKey: .url).singleValueContainer()

            if let str = try? singleContainer.decode(String.self),
               let urlValue = URL(string: str)
            {
                url = urlValue
            } else {
                throw DecodingError.typeMismatch(
                    URL.self,
                    .init(codingPath: decoder.codingPath, debugDescription: "Could not decode URL from string")
                )
            }
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["url": "https://www.example.com"]

    let result = try decoder.decode(URLWrapperModel.self, from: dict)
    #expect(result.url == URL(string: "https://www.example.com"))
}

// MARK: - Additional Numeric Type Coverage Tests

@Test func singleValueInt8Conversion() throws {
    struct Inner: Codable {
        let value: Int8
    }
    struct Wrapper: Codable {
        let inner: Inner
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["inner": ["value": NSNumber(value: 42)]]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.inner.value == 42)
}

@Test func singleValueInt16Conversion() throws {
    struct Inner: Codable {
        let value: Int16
    }
    struct Wrapper: Codable {
        let inner: Inner
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["inner": ["value": NSNumber(value: 1000)]]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.inner.value == 1000)
}

@Test func singleValueInt32Conversion() throws {
    struct Inner: Codable {
        let value: Int32
    }
    struct Wrapper: Codable {
        let inner: Inner
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["inner": ["value": NSNumber(value: 100_000)]]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.inner.value == 100_000)
}

@Test func singleValueInt64Conversion() throws {
    struct Inner: Codable {
        let value: Int64
    }
    struct Wrapper: Codable {
        let inner: Inner
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["inner": ["value": NSNumber(value: 9_223_372_036_854_775_807)]]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.inner.value == 9_223_372_036_854_775_807)
}

@Test func singleValueUIntConversion() throws {
    struct Inner: Codable {
        let value: UInt
    }
    struct Wrapper: Codable {
        let inner: Inner
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["inner": ["value": NSNumber(value: 42)]]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.inner.value == 42)
}

@Test func singleValueUInt8Conversion() throws {
    struct Inner: Codable {
        let value: UInt8
    }
    struct Wrapper: Codable {
        let inner: Inner
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["inner": ["value": NSNumber(value: 255)]]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.inner.value == 255)
}

@Test func singleValueUInt16Conversion() throws {
    struct Inner: Codable {
        let value: UInt16
    }
    struct Wrapper: Codable {
        let inner: Inner
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["inner": ["value": NSNumber(value: 65535)]]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.inner.value == 65535)
}

@Test func singleValueUInt32Conversion() throws {
    struct Inner: Codable {
        let value: UInt32
    }
    struct Wrapper: Codable {
        let inner: Inner
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["inner": ["value": NSNumber(value: 4_294_967_295)]]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.inner.value == 4_294_967_295)
}

@Test func singleValueUInt64Conversion() throws {
    struct Inner: Codable {
        let value: UInt64
    }
    struct Wrapper: Codable {
        let inner: Inner
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["inner": ["value": NSNumber(value: 18_446_744_073_709_551_615 as UInt64)]]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.inner.value == 18_446_744_073_709_551_615)
}

@Test func singleValueDoubleConversion() throws {
    struct Inner: Codable {
        let value: Double
    }
    struct Wrapper: Codable {
        let inner: Inner
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["inner": ["value": NSNumber(value: 3.14159)]]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.inner.value == 3.14159)
}

@Test func singleValueFloatConversion() throws {
    struct Inner: Codable {
        let value: Float
    }
    struct Wrapper: Codable {
        let inner: Inner
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["inner": ["value": NSNumber(value: Float(2.71828))]]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(abs(result.inner.value - 2.71828) < 0.0001)
}

@Test func singleValueBoolConversion() throws {
    struct Inner: Codable {
        let value: Bool
    }
    struct Wrapper: Codable {
        let inner: Inner
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["inner": ["value": NSNumber(value: true)]]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.inner.value == true)
}

@Test func singleValueIntConversion() throws {
    struct Inner: Codable {
        let value: Int
    }
    struct Wrapper: Codable {
        let inner: Inner
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["inner": ["value": NSNumber(value: 123)]]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.inner.value == 123)
}

@Test func singleValueNilError() throws {
    struct Inner: Codable {
        let value: String
    }
    struct Wrapper: Codable {
        let inner: Inner
    }

    let decoder = DictionaryCoder()
    #expect(throws: DecodingError.self) {
        _ = try decoder.decode(Wrapper.self, from: ["inner": ["value": NSNull()]])
    }
}

@Test func singleValueDataFromBase64() throws {
    struct Inner: Codable {
        let data: Data

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            data = try container.decode(Data.self)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(data)
        }
    }
    struct Wrapper: Codable {
        let inner: Inner
    }

    let decoder = DictionaryCoder()
    let base64String = "SGVsbG8gV29ybGQ="
    let dict: [String: Any] = ["inner": base64String]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(String(data: result.inner.data, encoding: .utf8) == "Hello World")
}

@Test func singleValueURLFromString() throws {
    struct Inner: Codable {
        let url: URL

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            url = try container.decode(URL.self)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(url)
        }
    }
    struct Wrapper: Codable {
        let inner: Inner
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["inner": "https://example.com"]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.inner.url == URL(string: "https://example.com"))
}

@Test func singleValueDataDirect() throws {
    struct Inner: Codable {
        let data: Data
    }
    struct Wrapper: Codable {
        let inner: Inner
    }

    let decoder = DictionaryCoder()
    let testData = Data([1, 2, 3, 4, 5])
    let dict: [String: Any] = ["inner": ["data": testData]]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.inner.data == testData)
}

// MARK: - KeyedContainer Numeric Conversion Tests

@Test func keyedIntConversion() throws {
    struct TestModel: Codable {
        let value: Int

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            value = try container.decode(Int.self, forKey: .value)
        }

        enum CodingKeys: String, CodingKey {
            case value
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["value": NSNumber(value: 42)]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.value == 42)
}

@Test func keyedDoubleConversion() throws {
    struct TestModel: Codable {
        let value: Double

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            value = try container.decode(Double.self, forKey: .value)
        }

        enum CodingKeys: String, CodingKey {
            case value
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["value": NSNumber(value: 3.14)]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.value == 3.14)
}

@Test func keyedFloatConversion() throws {
    struct TestModel: Codable {
        let value: Float

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            value = try container.decode(Float.self, forKey: .value)
        }

        enum CodingKeys: String, CodingKey {
            case value
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["value": NSNumber(value: Float(2.5))]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.value == 2.5)
}

@Test func keyedBoolConversion() throws {
    struct TestModel: Codable {
        let value: Bool

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            value = try container.decode(Bool.self, forKey: .value)
        }

        enum CodingKeys: String, CodingKey {
            case value
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["value": NSNumber(value: true)]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.value == true)
}

// MARK: - Cross-type numeric conversions to cover conversion code paths

@Test func singleValueContainerDirectNSNumberInt() throws {
    // This test specifically targets the NSNumber conversion in DictionarySingleValueDecodingContainer
    // Use a Double NSNumber to decode as Int - this forces conversion path
    struct Wrapper: Decodable {
        let value: CustomDecodable

        struct CustomDecodable: Decodable {
            let inner: Int

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                inner = try container.decode(Int.self)
            }
        }
    }

    let decoder = DictionaryCoder()
    // Create NSNumber from Double - cannot directly cast to Int
    let dict: [String: Any] = ["value": NSNumber(value: 42.0)]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.value.inner == 42)
}

@Test func singleValueContainerDirectNSNumberInt8() throws {
    struct Wrapper: Decodable {
        let value: CustomDecodable

        struct CustomDecodable: Decodable {
            let inner: Int8

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                inner = try container.decode(Int8.self)
            }
        }
    }

    let decoder = DictionaryCoder()
    // Use Double NSNumber to force conversion path
    let dict: [String: Any] = ["value": NSNumber(value: 100.0)]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.value.inner == 100)
}

@Test func singleValueContainerDirectNSNumberInt16() throws {
    struct Wrapper: Decodable {
        let value: CustomDecodable

        struct CustomDecodable: Decodable {
            let inner: Int16

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                inner = try container.decode(Int16.self)
            }
        }
    }

    let decoder = DictionaryCoder()
    // Use Double NSNumber to force conversion path
    let dict: [String: Any] = ["value": NSNumber(value: 1000.0)]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.value.inner == 1000)
}

@Test func singleValueContainerDirectNSNumberInt32() throws {
    struct Wrapper: Decodable {
        let value: CustomDecodable

        struct CustomDecodable: Decodable {
            let inner: Int32

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                inner = try container.decode(Int32.self)
            }
        }
    }

    let decoder = DictionaryCoder()
    // Use Double NSNumber to force conversion path
    let dict: [String: Any] = ["value": NSNumber(value: 100_000.0)]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.value.inner == 100_000)
}

@Test func singleValueContainerDirectNSNumberInt64() throws {
    struct Wrapper: Decodable {
        let value: CustomDecodable

        struct CustomDecodable: Decodable {
            let inner: Int64

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                inner = try container.decode(Int64.self)
            }
        }
    }

    let decoder = DictionaryCoder()
    // Use Double NSNumber to force conversion path
    let dict: [String: Any] = ["value": NSNumber(value: 9_999_999_999.0)]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.value.inner == 9_999_999_999)
}

@Test func singleValueContainerDirectNSNumberUInt() throws {
    struct Wrapper: Decodable {
        let value: CustomDecodable

        struct CustomDecodable: Decodable {
            let inner: UInt

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                inner = try container.decode(UInt.self)
            }
        }
    }

    let decoder = DictionaryCoder()
    // Use Double NSNumber to force conversion path
    let dict: [String: Any] = ["value": NSNumber(value: 42.0)]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.value.inner == 42)
}

@Test func singleValueContainerDirectNSNumberUInt8() throws {
    struct Wrapper: Decodable {
        let value: CustomDecodable

        struct CustomDecodable: Decodable {
            let inner: UInt8

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                inner = try container.decode(UInt8.self)
            }
        }
    }

    let decoder = DictionaryCoder()
    // Use Double NSNumber to force conversion path
    let dict: [String: Any] = ["value": NSNumber(value: 200.0)]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.value.inner == 200)
}

@Test func singleValueContainerDirectNSNumberUInt16() throws {
    struct Wrapper: Decodable {
        let value: CustomDecodable

        struct CustomDecodable: Decodable {
            let inner: UInt16

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                inner = try container.decode(UInt16.self)
            }
        }
    }

    let decoder = DictionaryCoder()
    // Use Double NSNumber to force conversion path
    let dict: [String: Any] = ["value": NSNumber(value: 50000.0)]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.value.inner == 50000)
}

@Test func singleValueContainerDirectNSNumberUInt32() throws {
    struct Wrapper: Decodable {
        let value: CustomDecodable

        struct CustomDecodable: Decodable {
            let inner: UInt32

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                inner = try container.decode(UInt32.self)
            }
        }
    }

    let decoder = DictionaryCoder()
    // Use Double NSNumber to force conversion path
    let dict: [String: Any] = ["value": NSNumber(value: 3_000_000_000.0)]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.value.inner == 3_000_000_000)
}

@Test func singleValueContainerDirectNSNumberUInt64() throws {
    struct Wrapper: Decodable {
        let value: CustomDecodable

        struct CustomDecodable: Decodable {
            let inner: UInt64

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                inner = try container.decode(UInt64.self)
            }
        }
    }

    let decoder = DictionaryCoder()
    // Use Double NSNumber to force conversion path
    let dict: [String: Any] = ["value": NSNumber(value: 15_000_000_000.0)]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.value.inner == 15_000_000_000)
}

@Test func singleValueContainerDirectNSNumberDouble() throws {
    struct Wrapper: Decodable {
        let value: CustomDecodable

        struct CustomDecodable: Decodable {
            let inner: Double

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                inner = try container.decode(Double.self)
            }
        }
    }

    let decoder = DictionaryCoder()
    // Use Int NSNumber to force conversion path
    let dict: [String: Any] = ["value": NSNumber(value: 3)]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.value.inner == 3.0)
}

@Test func singleValueContainerDirectNSNumberFloat() throws {
    struct Wrapper: Decodable {
        let value: CustomDecodable

        struct CustomDecodable: Decodable {
            let inner: Float

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                inner = try container.decode(Float.self)
            }
        }
    }

    let decoder = DictionaryCoder()
    // Use Int NSNumber to force conversion path
    let dict: [String: Any] = ["value": NSNumber(value: 3)]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(abs(result.value.inner - 3.0) < 0.0001)
}

@Test func singleValueContainerDirectNSNumberBool() throws {
    struct Wrapper: Decodable {
        let value: CustomDecodable

        struct CustomDecodable: Decodable {
            let inner: Bool

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                inner = try container.decode(Bool.self)
            }
        }
    }

    let decoder = DictionaryCoder()
    // Use Int NSNumber to force conversion path (1 -> true)
    let dict: [String: Any] = ["value": NSNumber(value: 1.0)]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.value.inner == true)
}

@Test func singleValueContainerDirectData() throws {
    // This test specifically targets the Data blob path in DictionarySingleValueDecodingContainer (line 69)
    struct Wrapper: Decodable {
        let value: CustomDecodable

        struct CustomDecodable: Decodable {
            let inner: Data

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                inner = try container.decode(Data.self)
            }
        }
    }

    let decoder = DictionaryCoder()
    let testData = Data([1, 2, 3, 4, 5])
    let dict: [String: Any] = ["value": testData]
    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.value.inner == testData)
}

// MARK: - KeyedContainer NSNumber Conversion Tests

@Test func keyedContainerNSNumberToIntConversion() throws {
    // This test targets the NSNumber conversion path in DictionaryKeyedDecodingContainer.decodeValue (line 116)
    // Use a Double NSNumber which doesn't bridge to Int
    struct TestModel: Decodable {
        let value: Int

        enum CodingKeys: String, CodingKey {
            case value
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            // This explicitly calls decode(Int.self, forKey:) which calls decodeValue
            value = try container.decode(Int.self, forKey: .value)
        }
    }

    let decoder = DictionaryCoder()
    // Create an NSNumber from Double - won't directly cast to Int (per bridging test)
    let nsNumber = NSNumber(value: 42.9 as Double)
    let dict: [String: Any] = ["value": nsNumber as Any]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.value == 42)
}

@Test func keyedContainerNSNumberToFloatConversion() throws {
    // Use a Double NSNumber which doesn't bridge to Float (per bridging test)
    struct TestModel: Decodable {
        let value: Float

        enum CodingKeys: String, CodingKey {
            case value
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            value = try container.decode(Float.self, forKey: .value)
        }
    }

    let decoder = DictionaryCoder()
    let nsNumber = NSNumber(value: 2.5 as Double)
    let dict: [String: Any] = ["value": nsNumber as Any]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(abs(result.value - 2.5) < 0.0001)
}

@Test func keyedContainerNSNumberToBoolConversion() throws {
    // Use an Int NSNumber which doesn't bridge to Bool (per bridging test)
    struct TestModel: Decodable {
        let value: Bool

        enum CodingKeys: String, CodingKey {
            case value
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            value = try container.decode(Bool.self, forKey: .value)
        }
    }

    let decoder = DictionaryCoder()
    let nsNumber = NSNumber(value: 1 as Int)
    let dict: [String: Any] = ["value": nsNumber as Any]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.value == true)
}

@Test func keyedContainerNSNumberInt64ToFloatConversion() throws {
    // Int64 NSNumber does not bridge to Float, forcing the conversion path at line 123
    struct TestModel: Decodable {
        let value: Float

        enum CodingKeys: String, CodingKey {
            case value
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            value = try container.decode(Float.self, forKey: .value)
        }
    }

    let decoder = DictionaryCoder()
    let nsNumber = NSNumber(value: 12345 as Int64)
    let dict: [String: Any] = ["value": nsNumber as Any]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(abs(result.value - 12345.0) < 0.0001)
}

@Test func keyedContainerNSNumberDoubleToFloatConversion() throws {
    // Double NSNumber does not bridge to Float, forcing the conversion path at line 123
    struct TestModel: Decodable {
        let value: Float

        enum CodingKeys: String, CodingKey {
            case value
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            value = try container.decode(Float.self, forKey: .value)
        }
    }

    let decoder = DictionaryCoder()
    let nsNumber = NSNumber(value: 3.14159 as Double)
    let dict: [String: Any] = ["value": nsNumber as Any]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(abs(result.value - 3.14159) < 0.001)
}

@Test func keyedContainerNSNumberUIntToBoolConversion() throws {
    // UInt NSNumber does not bridge to Bool, forcing the conversion path at line 126
    struct TestModel: Decodable {
        let value: Bool

        enum CodingKeys: String, CodingKey {
            case value
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            value = try container.decode(Bool.self, forKey: .value)
        }
    }

    let decoder = DictionaryCoder()
    let nsNumber = NSNumber(value: 5 as UInt)
    let dict: [String: Any] = ["value": nsNumber as Any]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.value == true) // Any non-zero value converts to true
}

// MARK: - SingleValueContainer Direct Type Match Test

@Test func singleValueDirectTypeMatch() throws {
    // This test targets the direct cast path in DictionarySingleValueDecodingContainer.decode (line 22)
    struct Inner: Decodable {
        let value: String

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            value = try container.decode(String.self)
        }
    }

    struct Wrapper: Decodable {
        let inner: Inner
    }

    let decoder = DictionaryCoder()
    // Pass a direct String to hit the direct cast path
    let dict: [String: Any] = ["inner": "direct string value"]

    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.inner.value == "direct string value")
}

@Test func singleValueStringToStringConversion() throws {
    // This test targets line 31 in DictionarySingleValueDecodingContainer.decode
    // where we check if T.self == String.self and storage is a String
    struct Inner: Decodable {
        let value: String

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            value = try container.decode(String.self)
        }
    }

    struct Wrapper: Decodable {
        let inner: Inner
    }

    let decoder = DictionaryCoder()
    // Use a String value
    let dict: [String: Any] = ["inner": "string value"]

    let result = try decoder.decode(Wrapper.self, from: dict)
    #expect(result.inner.value == "string value")
}

// MARK: - Additional tests for uncovered paths

@Test func superDecoderForKeyReturnsEmptyDictWhenMissing() throws {
    // This test specifically ensures line 77's ?? [:] fallback is hit
    // We need to call superDecoder(forKey:) with a missing key and actually USE the result
    struct TestModel: Decodable {
        let name: String
        let data: Any?

        enum CodingKeys: String, CodingKey {
            case name
            case missingKey
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)

            // Call superDecoder for a missing key - this triggers the ?? [:] path
            let superDec = try container.superDecoder(forKey: .missingKey)
            // Verify it returns a valid decoder with empty dict storage
            let superContainer = try superDec.singleValueContainer()
            data = try? superContainer.decode([String: String].self)
        }
    }

    let decoder = DictionaryCoder()
    let dict: [String: Any] = ["name": "Test"]

    let result = try decoder.decode(TestModel.self, from: dict)
    #expect(result.name == "Test")
}
