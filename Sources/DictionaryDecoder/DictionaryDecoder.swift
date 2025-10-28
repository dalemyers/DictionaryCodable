//
//  DictionaryDecoder.swift
//  PicklePro
//
//  Created by Dale Myers on 28/10/2025.
//

import Foundation

public final class DictionaryDecoder {
    public init() {}
    
    public var userInfo: [CodingUserInfoKey: Any] = [:]
    
    public func decode<T: Decodable>(_ type: T.Type, from dictionary: [String: Any]) throws -> T {
        let decoder = _DictionaryDecoder(storage: dictionary, userInfo: userInfo)
        return try T(from: decoder)
    }
}
