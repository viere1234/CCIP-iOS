//
//  Event.swift
//  OPass
//
//  Created by Brian Chang on 2023/7/30.
//  2024 OPass.
//

import Foundation

public struct EventInfo: Hashable, Codable, Identifiable {
    public let id: String
    public let title: LocalizedString
    public let logoUrl: String

    private enum CodingKeys: String, CodingKey {
        case id = "event_id"
        case title = "display_name"
        case logoUrl = "logo_url"
    }
}
