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
        .modelContainer(for: [MangaCollectionModel.self, PendingCollectionChange.self])
    }
}
