//
//  Speaker.swift
//  OPass
//
//  Created by Brian Chang on 2024/4/29.
//  2024 OPass.
//

import SwiftData

@Model public class Speaker: Decodable, Identifiable, Localizable {
    @Attribute(.unique) public var id: String
    public var avatar: String
    public var zh: SpeakerDetail
    public var en: SpeakerDetail

    public init(id: String, avatar: String, zh: SpeakerDetail, en: SpeakerDetail) {
        self.id = id
        self.avatar = avatar
        self.zh = zh
        self.en = en
    }

    private enum CodingKeys: CodingKey {
        case id, avatar, zh, en
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.avatar = try container.decode(String.self, forKey: .avatar)
        self.zh = try container.decode(SpeakerDetail.self, forKey: .zh)
        self.en = try container.decode(SpeakerDetail.self, forKey: .en)
    }
}

public struct SpeakerDetail: Hashable, Codable {
    var name: String
    var bio: String
}
