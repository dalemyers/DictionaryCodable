//
//  DictionaryUnkeyedDecodingContainer.swift
//  PicklePro
//
//  Created by Dale Myers on 28/10/2025.
//

import Foundation

struct DictionaryUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    let decoder: _DictionaryDecoder
    let storage: [Any]
    var codingPath: [CodingKey] { decoder.codingPath }

    var count: Int? { storage.count }
    var isAtEnd: Bool { currentIndex >= storage.count }
    var currentIndex: Int = 0

    mutating func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type)
        throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey
    {
        guard !isAtEnd else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: codingPath,
                    debugDescription: "Unkeyed container is at end"
                )
            )
        }
        let value = storage[currentIndex]
        currentIndex += 1
        guard let dict = value as? [String: Any] else {
            throw DecodingError.typeMismatch(
                [String: Any].self,
                .init(
                    codingPath: codingPath,
                    debugDescription: "Expected dictionary for nested container. Got: \(type(of: value))"
                )
            )
        }
        let nestedDecoder = _DictionaryDecoder(
            storage: dict,
            codingPath: codingPath,
            userInfo: decoder.userInfo
        )
        let container = DictionaryKeyedDecodingContainer<NestedKey>(
            decoder: nestedDecoder,
            storage: dict
        )
        return KeyedDecodingContainer(container)
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard !isAtEnd else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: codingPath,
                    debugDescription: "Unkeyed container is at end"
                )
            )
        }
        let value = storage[currentIndex]
        currentIndex += 1
        guard let array = value as? [Any] else {
            throw DecodingError.typeMismatch(
                [Any].self,
                .init(
                    codingPath: codingPath,
                    debugDescription: "Expected array for nested unkeyed container. Got: \(type(of: value))"
                )
            )
        }
        return DictionaryUnkeyedDecodingContainer(
            decoder: _DictionaryDecoder(
                storage: array,
                codingPath: codingPath,
                userInfo: decoder.userInfo
            ),
            storage: array
        )
    }

    mutating func superDecoder() throws -> Decoder {
        guard !isAtEnd else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: codingPath,
                    debugDescription: "Unkeyed container is at end"
                )
            )
        }
        let value = storage[currentIndex]
        currentIndex += 1
        return _DictionaryDecoder(
            storage: value,
            codingPath: codingPath,
            userInfo: decoder.userInfo
        )
    }

    mutating func decodeNil() throws -> Bool {
        guard !isAtEnd else { return true }
        if storage[currentIndex] is NSNull {
            currentIndex += 1
            return true
        }
        return false
    }

    mutating func decode<T: Decodable>(_: T.Type) throws -> T {
        guard !isAtEnd else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: codingPath,
                debugDescription: "Unkeyed container is at end"
            ))
        }
        let value = storage[currentIndex]
        currentIndex += 1

        if let val = value as? T { return val }
        let nestedDecoder = _DictionaryDecoder(storage: value, codingPath: codingPath, userInfo: decoder.userInfo)
        return try T(from: nestedDecoder)
    }
}
