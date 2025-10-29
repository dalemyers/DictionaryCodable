//
//  DictionarySingleValueDecodingContainer.swift
//  PicklePro
//
//  Created by Dale Myers on 28/10/2025.
//

import Foundation

struct DictionarySingleValueDecodingContainer: SingleValueDecodingContainer {
    let decoder: _DictionaryDecoder
    let storage: Any
    var codingPath: [CodingKey] { decoder.codingPath }

    func decodeNil() -> Bool {
        storage is NSNull
    }

    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        // 1) Direct cast for exact type match
        // Note: NSNumber bridges to Swift numeric types automatically, so NSNumber -> Int/Double/etc will succeed here
        if let val = storage as? T { return val }

        // 2) Handle NSNull / nil
        if storage is NSNull {
            throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: "Nil value found"))
        }

        // 3) String conversions
        if let str = storage as? String {
            // Note: String-to-String is handled by direct cast above (line 22)
            // Convert String -> numeric/bool if needed
            if T.self == Int.self, let v = Int(str) {
                return v as! T
            }
            if T.self == Double.self, let v = Double(str) {
                return v as! T
            }
            if T.self == Float.self, let v = Float(str) {
                return v as! T
            }
            if T.self == Bool.self {
                let lower = str.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                if ["true", "1", "yes", "y"].contains(lower) {
                    return true as! T
                }
                if ["false", "0", "no", "n"].contains(lower) {
                    return false as! T
                }
            }
            // Data from base64 string
            if T.self == Data.self, let d = Data(base64Encoded: str) {
                return d as! T
            }
            // URL from string
            if T.self == URL.self, let url = URL(string: str) {
                return url as! T
            }
        }

        // 4) Nothing matched — throw descriptive error
        throw DecodingError.typeMismatch(
            type,
            .init(
                codingPath: codingPath,
                debugDescription: "Cannot convert \(type) from stored value of type \(Swift.type(of: storage))"
            )
        )
    }
}
