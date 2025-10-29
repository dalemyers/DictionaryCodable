//
//  _DictionaryDecoder.swift
//  PicklePro
//
//  Created by Dale Myers on 28/10/2025.
//

import Foundation

final class _DictionaryDecoder: Decoder {
    var storage: Any
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any]

    init(storage: Any, codingPath: [CodingKey] = [], userInfo: [CodingUserInfoKey: Any] = [:]) {
        self.storage = storage
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

    func container<Key>(keyedBy _: Key.Type) throws -> KeyedDecodingContainer<Key> {
        guard let dict = storage as? [String: Any] else {
            throw DecodingError.typeMismatch(
                [String: Any].self,
                .init(codingPath: codingPath, debugDescription: "Expected dictionary but got: \(type(of: storage))")
            )
        }
        let container = DictionaryKeyedDecodingContainer<Key>(decoder: self, storage: dict)
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard let array = storage as? [Any] else {
            throw DecodingError.typeMismatch(
                [Any].self,
                .init(codingPath: codingPath, debugDescription: "Expected array but got: \(type(of: storage))")
            )
        }
        return DictionaryUnkeyedDecodingContainer(decoder: self, storage: array)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        DictionarySingleValueDecodingContainer(decoder: self, storage: storage)
    }
}
