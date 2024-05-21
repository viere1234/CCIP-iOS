//
//  Schedule.swift
//  OPass
//
//  Created by Brian Chang on 2024/4/29.
//  2024 OPass.
//

import SwiftData
import SwiftDate
import OrderedCollections

@Model public class Schedule: Decodable {
    @Relationship(deleteRule: .cascade)
    public var sessions: [OrderedDictionary<DateInRegion, [Session]>]
    @Relationship(deleteRule: .cascade)
    public var speakers: OrderedDictionary<String, Speaker>
    @Relationship(deleteRule: .cascade)
    public var types: OrderedDictionary<String, Tag>
    @Relationship(deleteRule: .cascade)
    public var rooms: OrderedDictionary<String, Tag>
    @Relationship(deleteRule: .cascade)
    public var tags: OrderedDictionary<String, Tag>

    public init(sessions: [OrderedDictionary<DateInRegion, [Session]>], speakers: OrderedDictionary<String, Speaker>, types: OrderedDictionary<String, Tag>, rooms: OrderedDictionary<String, Tag>, tags: OrderedDictionary<String, Tag>) {
        self.sessions = sessions
        self.speakers = speakers
        self.types = types
        self.rooms = rooms
        self.tags = tags
    }

    private enum CodingKeys: CodingKey {
        case sessions, speakers, session_types, room, tags
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let sessions = try container.decode([Session].self, forKey: .sessions)
        let speakers = try container.decode([Speaker].self, forKey: .speakers)
        let types = try container.decode([Tag].self, forKey: .session_types)
        let rooms = try container.decode([Tag].self, forKey: .room)
        let tags = try container.decode([Tag].self, forKey: .tags)
        self.sessions = Dictionary(grouping: sessions) { $0.start.dateTruncated(from: .hour)! }
            .sorted { $0.key < $1.key }
            .map { $0.value.sorted { $0.start < $1.start } }
            .map { OrderedDictionary(grouping: $0, by: \.start) }
            .map { $0.mapValues { $0.sorted { $0.end < $1.end } } }
        self.speakers = OrderedDictionary(uniqueKeysWithValues: speakers.map {($0.id, $0)})
        self.types = OrderedDictionary(uniqueKeysWithValues: types.map {($0.id, $0)})
        self.rooms = OrderedDictionary(uniqueKeysWithValues: rooms.map {($0.id, $0)})
        self.tags = OrderedDictionary(uniqueKeysWithValues: tags.map {($0.id, $0)})
    }
}
