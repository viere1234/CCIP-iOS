//
//  Session.swift
//  OPass
//
//  Created by Brian Chang on 2024/4/29.
//  2024 OPass.
//

import SwiftData
import SwiftDate

@Model public class Session: Decodable, Identifiable, Localizable {
    @Attribute(.unique) public var id: String
    var type: String?
    var room: String
    var broadcast: [String]?
    var start: DateInRegion
    var end: DateInRegion
    var co_write: String?
    var qa: String?
    var slide: String?
    var live: String?
    var record: String?
    var language: String?
    var uri: String?
    var zh: SessionDetail
    var en: SessionDetail
    var speakers: [String]
    var tags: [String]

    public init(id: String, type: String? = nil, room: String, broadcast: [String]? = nil, start: DateInRegion, end: DateInRegion, co_write: String? = nil, qa: String? = nil, slide: String? = nil, live: String? = nil, record: String? = nil, language: String? = nil, uri: String? = nil, zh: SessionDetail, en: SessionDetail, speakers: [String], tags: [String]) {
        self.id = id
        self.type = type
        self.room = room
        self.broadcast = broadcast
        self.start = start
        self.end = end
        self.co_write = co_write
        self.qa = qa
        self.slide = slide
        self.live = live
        self.record = record
        self.language = language
        self.uri = uri
        self.zh = zh
        self.en = en
        self.speakers = speakers
        self.tags = tags
    }

    private enum CodingKeys: CodingKey {
        case id, type, room, broadcast, start, end, co_write, qa, slide, live, record, language, uri, zh, en, speakers, tags
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.room = try container.decode(String.self, forKey: .room)
        self.broadcast = try container.decodeIfPresent([String].self, forKey: .broadcast)
        self.start = try .init(iso: try container.decode(String.self, forKey: .start))
        self.end = try .init(iso: try container.decode(String.self, forKey: .end))
        self.co_write = try container.decodeIfPresent(String.self, forKey: .co_write)
        self.qa = try container.decodeIfPresent(String.self, forKey: .qa)
        self.slide = try container.decodeIfPresent(String.self, forKey: .slide)
        self.live = try container.decodeIfPresent(String.self, forKey: .live)
        self.record = try container.decodeIfPresent(String.self, forKey: .record)
        self.language = try container.decodeIfPresent(String.self, forKey: .language)
        self.uri = try container.decodeIfPresent(String.self, forKey: .uri)
        self.zh = try container.decode(SessionDetail.self, forKey: .zh)
        self.en = try container.decode(SessionDetail.self, forKey: .en)
        self.speakers = try container.decode([String].self, forKey: .speakers)
        self.tags = try container.decode([String].self, forKey: .tags)
    }
}

public struct SessionDetail: Hashable, Codable {
    public var title: String
    public var description: String
}
