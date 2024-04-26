//
//  LocalizedString.swift
//  OPass
//
//  Created by Brian Chang on 2023/7/30.
//  2024 OPass.
//

import Foundation

public struct LocalizedString: Hashable, Codable, Localizable {
    var zh: String
    var en: String
}

public struct LocalizedCodeString: Hashable, Codable, Localizable {
    var zh: String
    var en: String

    private enum CodingKeys: String, CodingKey {
        case zh = "zh-TW"
        case en = "en-US"
    }
}

protocol Localizable {
    associatedtype T
    var zh: T { get }
    var en: T { get }
}

extension Localizable {
    @inline(__always)
    public func localized() -> T {
        switch Bundle.main.preferredLocalizations[0] {
        case "zh-Hant": return self.zh
        default: return self.en
        }
    }
}
