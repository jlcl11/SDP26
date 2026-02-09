//
//  SDP26App.swift
//  SDP26
//
//  Created by José Luis Corral López on 28/1/26.
//

import SwiftUI
import SwiftData

@main
struct SDP26App: App {
    @State private var session = AuthViewModel.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if session.isLoggedIn {
                    ContentView()
                } else {
                    LoginView()
                }
            }
            .environment(session)
        }
        .modelContainer(SharedModelContainer.create())
    }
}

// MARK: - Shared Model Container

/// Provides a shared ModelContainer for both the main app and widgets
/// using App Groups to share the SwiftData store.
enum SharedModelContainer {
    static let appGroupIdentifier = "group.prueba.SDP26"

    static func create() -> ModelContainer {
        let schema = Schema([
            MangaCollectionModel.self,
            PendingCollectionChange.self
        ])

        let configuration: ModelConfiguration

        if let appGroupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) {
            let storeURL = appGroupURL.appendingPathComponent("MangaCollection.store")
            configuration = ModelConfiguration(
                "MangaCollection",
                schema: schema,
                url: storeURL,
                cloudKitDatabase: .none
            )
        } else {
            // Fallback for previews or if App Group is not configured
            configuration = ModelConfiguration(
                "MangaCollection",
                schema: schema,
                cloudKitDatabase: .none
            )
        }

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
