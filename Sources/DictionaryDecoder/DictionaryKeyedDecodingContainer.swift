//
//  DictionaryKeyedDecodingContainer.swift
//  PicklePro
//
//  Created by Dale Myers on 28/10/2025.
//

import Foundation

// MARK: - Keyed Container

struct DictionaryKeyedDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {
    let decoder: _DictionaryDecoder
    let storage: [String: Any]

    var codingPath: [CodingKey] { decoder.codingPath }
    var allKeys: [K] { storage.keys.compactMap { K(stringValue: $0) } }

    func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type, forKey key: K)
        throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey
    {
        guard let value = storage[key.stringValue] else {
            throw DecodingError.keyNotFound(
                key,
                .init(
                    codingPath: codingPath,
                    debugDescription: "Missing key for nested container \(key.stringValue)"
                )
            )
        }
        guard let dict = value as? [String: Any] else {
            throw DecodingError.typeMismatch(
                [String: Any].self,
                .init(
                    codingPath: codingPath + [key],
                    debugDescription: "Expected nested dictionary at key \(key.stringValue). Got: \(type(of: value))"
                )
            )
        }
        let nestedDecoder = _DictionaryDecoder(
            storage: dict,
            codingPath: codingPath + [key],
            userInfo: decoder.userInfo
        )
        let container = DictionaryKeyedDecodingContainer<NestedKey>(
            decoder: nestedDecoder,
            storage: dict
        )
        return KeyedDecodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        guard let value = storage[key.stringValue] else {
            throw DecodingError.keyNotFound(
                key,
                .init(
                    codingPath: codingPath,
                    debugDescription: "Missing key for nested unkeyed container \(key.stringValue)"
                )
            )
        }
        guard let array = value as? [Any] else {
            throw DecodingError.typeMismatch(
                [Any].self,
                .init(
                    codingPath: codingPath + [key],
                    debugDescription: "Expected array at key \(key.stringValue). Got: \(type(of: value))"
                )
            )
        }
        return DictionaryUnkeyedDecodingContainer(
            decoder: _DictionaryDecoder(
                storage: array,
                codingPath: codingPath + [key],
                userInfo: decoder.userInfo
            ),
            storage: array
        )
    }

    func superDecoder() throws -> Decoder {
        _DictionaryDecoder(
            storage: storage,
            codingPath: codingPath,
            userInfo: decoder.userInfo
        )
    }

    func superDecoder(forKey key: K) throws -> Decoder {
        let value = storage[key.stringValue] ?? [:]
        return _DictionaryDecoder(
            storage: value,
            codingPath: codingPath + [key],
            userInfo: decoder.userInfo
        )
    }

    func contains(_ key: K) -> Bool {
        storage[key.stringValue] != nil
    }

    func decodeNil(forKey key: K) throws -> Bool {
        storage[key.stringValue] is NSNull || storage[key.stringValue] == nil
    }

    func decode<T: Decodable>(_ type: T.Type, forKey key: K) throws -> T {
        guard let value = storage[key.stringValue] else {
            throw DecodingError.keyNotFound(key, .init(codingPath: codingPath, debugDescription: "Missing key"))
        }
        return try decodeValue(type, from: value, key: key)
    }

    private func decodeValue<T: Decodable>(_: T.Type, from value: Any, key: K) throws -> T {
        // Direct type match
        if let val = value as? T { return val }

        // Handle nested dictionary
        if let dict = value as? [String: Any] {
            let nestedDecoder = _DictionaryDecoder(
                storage: dict,
                codingPath: codingPath + [key],
                userInfo: decoder.userInfo
            )
            return try T(from: nestedDecoder)
        }

        // Handle array
        if let arr = value as? [Any] {
            let nestedDecoder = _DictionaryDecoder(
                storage: arr,
                codingPath: codingPath + [key],
                userInfo: decoder.userInfo
            )
            return try T(from: nestedDecoder)
        }

        // Handle numeric conversion for types that don't bridge directly from NSNumber
        if let number = value as? NSNumber {
            // Int conversion: needed when NSNumber contains a floating-point value
            if T.self == Int.self {
                return number.intValue as! T
            }
            // Float conversion: needed when NSNumber contains Int64, UInt64, or Double
            if T.self == Float.self {
                return number.floatValue as! T
            }
            // Bool conversion: needed when NSNumber contains any non-Bool numeric value
            if T.self == Bool.self {
                return number.boolValue as! T
            }
            // Note: Double conversion is not needed here as all NSNumbers bridge to Double
        }

        // Fallback to single value decode
        let singleDecoder = _DictionaryDecoder(storage: value, codingPath: codingPath + [key], userInfo: decoder.userInfo)
        return try T(from: singleDecoder)
    }
}
