//
//  DictionarySingleValueEncodingContainer.swift
//  PicklePro
//
//  Created by Dale Myers on 28/10/2025.
//

import Foundation

struct DictionarySingleValueEncodingContainer: SingleValueEncodingContainer {
    let encoder: _DictionaryEncoder

    var codingPath: [CodingKey] { encoder.codingPath }

    mutating func encodeNil() throws {
        encoder.storage.value = NSNull()
    }

    mutating func encode(_ value: some Encodable) throws {
        // Handle primitives directly
        if let val = value as? String {
            encoder.storage.value = val
            return
        }
        if let val = value as? Int {
            encoder.storage.value = val
            return
        }
        if let val = value as? Double {
            encoder.storage.value = val
            return
        }
        if let val = value as? Float {
            encoder.storage.value = val
            return
        }
        if let val = value as? Bool {
            encoder.storage.value = val
            return
        }
        if let val = value as? Int8 {
            encoder.storage.value = val
            return
        }
        if let val = value as? Int16 {
            encoder.storage.value = val
            return
        }
        if let val = value as? Int32 {
            encoder.storage.value = val
            return
        }
        if let val = value as? Int64 {
            encoder.storage.value = val
            return
        }
        if let val = value as? UInt {
            encoder.storage.value = val
            return
        }
        if let val = value as? UInt8 {
            encoder.storage.value = val
            return
        }
        if let val = value as? UInt16 {
            encoder.storage.value = val
            return
        }
        if let val = value as? UInt32 {
            encoder.storage.value = val
            return
        }
        if let val = value as? UInt64 {
            encoder.storage.value = val
            return
        }

        // For complex types, encode them
        try value.encode(to: encoder)
    }
}
