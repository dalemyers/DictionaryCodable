//
//  DictionaryDecoder.swift
//  PicklePro
//
//  Created by Dale Myers on 28/10/2025.
//

import Foundation

public final class DictionaryCoder {
    public init() {}

    public var userInfo: [CodingUserInfoKey: Any] = [:]

    public func decode<T: Decodable>(_: T.Type, from dictionary: [String: Any]) throws -> T {
        let decoder = _DictionaryCoder(storage: dictionary, userInfo: userInfo)
        return try T(from: decoder)
    }
}
