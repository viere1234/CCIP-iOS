//
//  File.swift
//  
//
//  Created by Brian Chang on 2024/4/28.
//

import SwiftData
import SwiftDate

@Model public class Scenario: Decodable, Identifiable {
    public var id: String
    public var order: Int
    public var title: LocalizedCodeString
    public var disabled: String?
    public var available: DateInRegion
    public var expire: DateInRegion
    public var countdown: Int
    public var attributes: [String : String]
    public var used: DateInRegion?

    public init(id: String, order: Int, title: LocalizedCodeString, disabled: String? = nil, available: DateInRegion, expire: DateInRegion, countdown: Int, attributes: [String : String], used: DateInRegion? = nil) {
        self.id = id
        self.order = order
        self.title = title
        self.disabled = disabled
        self.available = available
        self.expire = expire
        self.countdown = countdown
        self.attributes = attributes
        self.used = used
    }

    private enum CodingKeys: CodingKey {
        case id, order, display_text, disabled, available_time, expire_time, countdown, attr, used
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.order = try container.decode(Int.self, forKey: .order)
        self.title = try container.decode(LocalizedCodeString.self, forKey: .display_text)
        self.available = .init(seconds: .init(try container.decode(Int.self, forKey: .available_time)), region: .current)
        self.expire = .init(seconds: .init(try container.decode(Int.self, forKey: .expire_time)), region: .current)
        self.countdown = try container.decode(Int.self, forKey: .countdown)
        self.attributes = try container.decode([String : String].self, forKey: .attr)
        let used = try container.decodeIfPresent(Int.self, forKey: .used)
        self.used = used == nil ? nil : .init(seconds: .init(used!), region: .current)
    }
}

extension Scenario {
    @inline(__always)
    var symbol: String {
        switch id {
        case _ where id.contains("breakfast") || id.contains("lunch") || id.contains("dinner"):
            return "takeoutbag.and.cup.and.straw"
        case _ where id.contains("checkin") || id.contains("checkout"):
            return "pencil"
        case _ where id.contains("vipkit"):
            return "gift"
        case _ where id.contains("kit"):
            return "bag"
        default:
            return "squareshape.squareshape.dashed"
        }
    }
}
