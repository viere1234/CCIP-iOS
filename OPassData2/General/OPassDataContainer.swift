//
//  OPassDataContainer.swift
//  OPass
//
//  Created by Brian Chang on 2024/4/24.
//  2024 OPass.
//

import SwiftUI
import SwiftData

struct OPassDataContainer: ViewModifier {
    let container: ModelContainer

    static let schema = SwiftData.Schema([
        Event.self,
        EventConfig.self,
        Feature.self
    ])

    init (inMemory: Bool) {
        container = try! ModelContainer(
            for: OPassDataContainer.schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: inMemory)])
    }

    func body(content: Content) -> some View {
        content
            .modelContainer(container)
    }
}

public extension View {
    func opassDataContainer(inMemory: Bool = false) -> some View {
        modifier(OPassDataContainer(inMemory: inMemory))
    }
}
