//
//  DictionaryKeyedEncodingContainer.swift
//  PicklePro
//
//  Created by Dale Myers on 28/10/2025.
//

import Foundation

struct DictionaryKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    let encoder: _DictionaryEncoder

    var codingPath: [CodingKey] { encoder.codingPath }

    private var storage: [String: Any] {
        get { encoder.storage.value as? [String: Any] ?? [:] }
        set { encoder.storage.value = newValue }
    }

    mutating func nestedContainer<NestedKey>(
        keyedBy _: NestedKey.Type,
        forKey key: K
    ) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let nestedStorage = _DictionaryEncoder.Storage([String: Any]())
        let nestedEncoder = _DictionaryEncoder(
            codingPath: codingPath + [key],
            userInfo: encoder.userInfo,
            storage: nestedStorage
        )
        var dict = storage
        dict[key.stringValue] = nestedStorage.value
        storage = dict
        let container = DictionaryKeyedEncodingContainer<NestedKey>(encoder: nestedEncoder)
        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        let nestedStorage = _DictionaryEncoder.Storage([Any]())
        let nestedEncoder = _DictionaryEncoder(
            codingPath: codingPath + [key],
            userInfo: encoder.userInfo,
            storage: nestedStorage
        )
        var dict = storage
        dict[key.stringValue] = nestedStorage.value
        storage = dict
        return DictionaryUnkeyedEncodingContainer(encoder: nestedEncoder)
    }

    mutating func superEncoder() -> Encoder {
        _DictionaryEncoder(codingPath: codingPath, userInfo: encoder.userInfo)
    }

    mutating func superEncoder(forKey key: K) -> Encoder {
        _DictionaryEncoder(codingPath: codingPath + [key], userInfo: encoder.userInfo)
    }

    mutating func encodeNil(forKey key: K) throws {
        var dict = storage
        dict[key.stringValue] = NSNull()
        storage = dict
    }

    mutating func encode(_ value: some Encodable, forKey key: K) throws {
        var dict = storage
        dict[key.stringValue] = try encodeValue(value, forKey: key)
        storage = dict
    }

    private func encodeValue(_ value: some Encodable, forKey key: K) throws -> Any {
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
            codingPath: codingPath + [key],
            userInfo: encoder.userInfo,
            storage: nestedStorage
        )
        try value.encode(to: nestedEncoder)
        return nestedStorage.value
    }
}
