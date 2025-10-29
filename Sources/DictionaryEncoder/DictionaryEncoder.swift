//
//  DictionaryEncoder.swift
//  PicklePro
//
//  Created by Dale Myers on 28/10/2025.
//

import Foundation

public final class DictionaryEncoder {
    public init() {}

    public var userInfo: [CodingUserInfoKey: Any] = [:]

    public func encode(_ value: some Encodable) throws -> [String: Any] {
        let encoder = _DictionaryEncoder(userInfo: userInfo)
        try value.encode(to: encoder)
        guard let result = encoder.storage.value as? [String: Any] else {
            throw EncodingError.invalidValue(
                value,
                .init(codingPath: [], debugDescription: "Top-level value must encode to a dictionary")
            )
        }
        return result
    }
}
