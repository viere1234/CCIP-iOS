//
//  ModelPreview.swift
//  OPass
//
//  Created by Brian Chang on 2024/4/27.
//  2024 OPass.
//

import SwiftUI
import SwiftData

public struct ModelPreview<Model: PersistentModel, Content: View>: View {
    var content: (Model) -> Content

    public init(@ViewBuilder content: @escaping (Model) -> Content) {
        self.content = content
    }

    public var body: some View {
        ZStack {
            PreviewContentView(content: content)
        }
        .opassDataContainer(inMemory: true)
    }

    struct PreviewContentView: View {
        var content: (Model) -> Content

        @Query private var models: [Model]
        @State private var waitedToShowIssue = false

        var body: some View {
            if let model = models.first {
                content(model)
            } else {
                ContentUnavailableView {
                    Label {
                        Text(verbatim: "Could not load model for previews")
                    } icon: {
                        Image(systemName: "xmark")
                    }
                }
                .opacity(waitedToShowIssue ? 1 : 0)
                .task {
                    Task {
                        try await Task.sleep(for: .seconds(1))
                        waitedToShowIssue = true
                    }
                }
            }
        }
    }
}
