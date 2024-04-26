//
//  Feature.swift
//
//
//  Created by Brian Chang on 2024/4/25.
//

import SwiftUI
import SwiftData

@Model public class Feature: Decodable {
    public let feature: FeatureType
    public var icon: String?
    public var iconData: Data?
    public var title: LocalizedString
    public var visibleRoles: [String]?
    public var wifi: [Wifi]?
    public var url: String?

    init() {
        self.feature = .webview
        self.title = .init(zh: "", en: "")
    }

    private enum CodingKeys: CodingKey {
        case feature, icon, display_text, visible_roles, wifi, url
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.feature = try container.decode(FeatureType.self, forKey: .feature)
        self.icon = try container.decodeIfPresent(String.self, forKey: .icon)
        self.title = try container.decode(LocalizedString.self, forKey: .display_text)
        self.visibleRoles = try container.decodeIfPresent([String].self, forKey: .visible_roles)
        self.wifi = try container.decodeIfPresent([Wifi].self, forKey: .wifi)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
    }
}

public enum FeatureType: String, Hashable, Codable {
    case fastpass, ticket, schedule, announcement, wifi, telegram, im, puzzle, venue, sponsors, staffs, webview
}

public struct Wifi: Hashable, Codable {
    public var ssid: String
    public var password: String

    private enum CodingKeys: String, CodingKey {
        case ssid = "SSID"
        case password
    }
}
