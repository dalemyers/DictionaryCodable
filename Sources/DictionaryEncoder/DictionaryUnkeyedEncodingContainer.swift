//
//  DictionaryUnkeyedEncodingContainer.swift
//  PicklePro
//
//  Created by Dale Myers on 28/10/2025.
//

import Foundation

struct DictionaryUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    let encoder: _DictionaryEncoder

    var codingPath: [CodingKey] { encoder.codingPath }
    var count: Int {
        (encoder.storage.value as? [Any])?.count ?? 0
    }

    private var storage: [Any] {
        get { encoder.storage.value as? [Any] ?? [] }
        set { encoder.storage.value = newValue }
    }

    mutating func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type) -> KeyedEncodingContainer<NestedKey>
        where NestedKey: CodingKey
    {
        let nestedStorage = _DictionaryEncoder.Storage([String: Any]())
        let nestedEncoder = _DictionaryEncoder(
            codingPath: codingPath,
            userInfo: encoder.userInfo,
            storage: nestedStorage
        )
        var array = storage
        array.append(nestedStorage.value)
        storage = array
        let container = DictionaryKeyedEncodingContainer<NestedKey>(encoder: nestedEncoder)
        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let nestedStorage = _DictionaryEncoder.Storage([Any]())
        let nestedEncoder = _DictionaryEncoder(
            codingPath: codingPath,
            userInfo: encoder.userInfo,
            storage: nestedStorage
        )
        var array = storage
        array.append(nestedStorage.value)
        storage = array
        return DictionaryUnkeyedEncodingContainer(encoder: nestedEncoder)
    }

    mutating func superEncoder() -> Encoder {
        _DictionaryEncoder(codingPath: codingPath, userInfo: encoder.userInfo)
    }

    mutating func encodeNil() throws {
        var array = storage
        array.append(NSNull())
        storage = array
    }

    mutating func encode(_ value: some Encodable) throws {
        var array = storage
        try array.append(encodeValue(value))
        storage = array
    }

    private func encodeValue(_ value: some Encodable) throws -> Any {
        // Handle primitives directly
        if let val = value as? String { return val }
        if let val = value as? Int { return val }
        if let val = value as? Double { return val }
        if let val = value as? Float { return val }
        if let val = value as? Bool { return val }
        if let val = value as? Int8 { return val }
        if let val = value as? Int16 { return val }
        if let val = value as? Int32 { return val }
        if let val = value as? Int64 { return val }
        if let val = value as? UInt { return val }
        if let val = value as? UInt8 { return val }
        if let val = value as? UInt16 { return val }
        if let val = value as? UInt32 { return val }
        if let val = value as? UInt64 { return val }

        // Handle nested encoding
        let nestedStorage = _DictionaryEncoder.Storage()
        let nestedEncoder = _DictionaryEncoder(
            codingPath: codingPath,
            userInfo: encoder.userInfo,
            storage: nestedStorage
        )
        try value.encode(to: nestedEncoder)
        return nestedStorage.value
    }
}
