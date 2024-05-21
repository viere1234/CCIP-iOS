//
//  Event.swift
//
//
//  Created by Brian Chang on 2024/4/24.
//

import OSLog
import SwiftData
import KeychainAccess

private let logger = Logger(subsystem: "OPassData", category: "Event")

@Model public class Event: Identifiable {
    @Attribute(.unique) private let model = "single"

    @Attribute(.unique) public let id: String
    @Relationship(.unique, deleteRule: .cascade)
    public var config: EventConfig
    @Relationship(deleteRule: .cascade)
    public var attendee: Attendee?

    @Transient private let keychain = Keychain(service: "app.opass.ccip.token").synchronizable(true)
    public var token: String? {
        get { try? keychain.get("\(self.id)_token") }
        set { keychain["\(self.id)_token"] = newValue }
    }

    init(id: String, config: EventConfig) {
        self.id = id
        self.config = config
    }
}

extension Event {
    static func load(id: String, modelContext: ModelContext) async throws {
        let config: EventConfig = try await URLSession.fetch(for: "https://portal.opass.app/events/\(id)")
        modelContext.insert(config)
        let event = Event(id: id, config: config)
        modelContext.insert(event)
    }
}
