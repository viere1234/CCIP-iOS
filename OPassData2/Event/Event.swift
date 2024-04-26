//
//  Event.swift
//
//
//  Created by Brian Chang on 2024/4/24.
//

import OSLog
import SwiftData

private let logger = Logger(subsystem: "OPassData", category: "Event")

@Model public class Event: Identifiable {
    @Attribute(.unique) private let model = "single"

    @Attribute(.unique) public let id: String
    @Relationship(.unique, deleteRule: .cascade)
    public var config: EventConfig

    init(id: String, config: EventConfig) {
        self.id = id
        self.config = config
    }
}

extension Event {
    static func load(id: String, modelContext: ModelContext) async throws {
        let config: EventConfig = try await fetch(from: "https://portal.opass.app/events/\(id)")
        let event = Event(id: id, config: config)
        modelContext.insert(event)
    }
}
