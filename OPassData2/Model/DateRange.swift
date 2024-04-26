//
//  File.swift
//  
//
//  Created by Brian Chang on 2024/4/25.
//

import SwiftDate

public struct DateRange: Hashable, Codable {
    public var start: DateInRegion
    public var end: DateInRegion

    private enum CodingKeys: CodingKey {
        case start, end
    }

    public init() {
        self.start = DateInRegion()
        self.end = DateInRegion()
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.start = try .init(iso: try container.decode(String.self, forKey: .start))
        self.end = try .init(iso: try container.decode(String.self, forKey: .end))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(start.toISO(), forKey: .start)
        try container.encode(end.toISO(), forKey: .end)
    }
}

extension DateInRegion {
    init(iso: String) throws {
        guard let date = iso.toISODate(region: .current) else {
            throw DecodingError.typeMismatch(
                DateInRegion.self, .init(
                    codingPath: [],
                    debugDescription: "String: \"\(iso)\" can't be decoded to DateInRegion"
                )
            )
        }
        self = date
    }
}
