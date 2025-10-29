//
//  _DictionaryEncoder.swift
//  PicklePro
//
//  Created by Dale Myers on 28/10/2025.
//

import Foundation

final class _DictionaryEncoder: Encoder {
    final class Storage {
        var value: Any

        init(_ value: Any = [String: Any]()) {
            self.value = value
        }
    }

    let storage: Storage
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any]

    init(codingPath: [CodingKey] = [], userInfo: [CodingUserInfoKey: Any] = [:], storage: Storage? = nil) {
        self.codingPath = codingPath
        self.userInfo = userInfo
        self.storage = storage ?? Storage()
    }

    func container<Key>(keyedBy _: Key.Type) -> KeyedEncodingContainer<Key> {
        if !(storage.value is [String: Any]) {
            storage.value = [String: Any]()
        }
        let container = DictionaryKeyedEncodingContainer<Key>(encoder: self)
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        if !(storage.value is [Any]) {
            storage.value = [Any]()
        }
        return DictionaryUnkeyedEncodingContainer(encoder: self)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        DictionarySingleValueEncodingContainer(encoder: self)
    }
}
