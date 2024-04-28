//
//  EventConfig.swift
//  OPass
//
//  Created by Brian Chang on 2024/4/25.
//  2024 OPass.
//

import SwiftData

@Model public class EventConfig: Decodable, Identifiable {
    @Attribute(.unique) public var id: String
    public var title: LocalizedString
    public var logoURL: String
    public var website: String?
    public var date: DateRange
    public var publish: DateRange
    @Relationship(deleteRule: .cascade)
    public var features: [Feature]

    init (id: String) {
        self.id = id
        self.title = .init(zh: "", en: "")
        self.logoURL = ""
        self.date = DateRange()
        self.publish = DateRange()
        self.features = []
    }

    private enum CodingKeys: CodingKey {
        case event_id, display_name, logo_url, event_website, event_date, publish, features
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .event_id)
        self.title = try container.decode(LocalizedString.self, forKey: .display_name)
        self.logoURL = try container.decode(String.self, forKey: .logo_url)
        self.website = try container.decodeIfPresent(String.self, forKey: .event_website)
        self.date = try container.decode(DateRange.self, forKey: .event_date)
        self.publish = try container.decode(DateRange.self, forKey: .publish)
        self.features = try container.decode([Feature].self, forKey: .features)
    }
}

extension EventConfig {
    @inline(__always)
    func feature(_ type: FeatureType) -> Feature? {
        return features.first { $0.feature == type }
    }
}
