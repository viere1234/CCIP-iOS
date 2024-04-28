//
//  Attendee.swift
//  OPass
//
//  Created by Brian Chang on 2024/4/27.
//  2024 OPass.
//

import SwiftData
import SwiftDate
import OrderedCollections

@Model public class Attendee: Decodable, Identifiable {
    @Attribute(.unique) public var id: String
    @Attribute(.unique) public var eventID: String
    public var userID: String?
    public var token: String
    public var role: String
    public var attributes: [String : String]
    public var firstUse: DateInRegion
    public var scenarios: OrderedDictionary<String, [Scenario]>

    public init(id: String, eventID: String, userID: String? = nil, token: String, role: String, attributes: [String : String], firstUse: DateInRegion, scenarios: OrderedDictionary<String, [Scenario]>) {
        self.id = id
        self.eventID = eventID
        self.userID = userID
        self.token = token
        self.role = role
        self.attributes = attributes
        self.firstUse = firstUse
        self.scenarios = scenarios
    }

    private enum CodingKeys: CodingKey {
        case _id, event_id, user_id, token, role, attr, first_use, scenarios
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode([String:String].self, forKey: ._id)["$oid"]!
        self.eventID = try container.decode(String.self, forKey: .event_id)
        self.userID = try container.decodeIfPresent(String.self, forKey: .user_id)
        self.token = try container.decode(String.self, forKey: .token)
        self.role = try container.decode(String.self, forKey: .role)
        self.attributes = try container.decode([String:String].self, forKey: .attr)
        self.firstUse = .init(seconds: .init(try container.decode(Int.self, forKey: .first_use)), region: .current)
        let scenarios = try container.decode([Scenario].self, forKey: .scenarios).sorted { $0.order < $1.order }
        var result: OrderedDictionary<String, [Scenario]> = [:]
        for scenario in scenarios {
            var index = 3, key = scenario.id
            if key.contains("day") {
                while(key[key.index(key.startIndex, offsetBy: index+1)].isNumber) { index += 1 }
                let range = ...key.index(key.startIndex, offsetBy: index)
                key = "\(key[range]) • \(scenario.available.month)/\(scenario.available.day)"
                key.insert(" ", at: key.index(key.startIndex, offsetBy: 3))
            } else if key.contains("kit") { key = "kit" }
            result.updateValue(forKey: key, default: []) { $0.append(scenario) }
        }
        var lastDayIndex = result.keys.lastIndex { $0.contains("day") } ?? 0
        for index in 0 ..< lastDayIndex {
            if !result.keys[index].contains("day") {
                result.swapAt(index, lastDayIndex)
                lastDayIndex = result.keys.lastIndex { $0.contains("day") } ?? 0
            }
        }
        self.scenarios = result
    }
}
