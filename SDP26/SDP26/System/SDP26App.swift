//
//  SDP26App.swift
//  SDP26
//
//  Created by José Luis Corral López on 28/1/26.
//

import SwiftUI

@main
struct SDP26App: App {
    @State private var authVM = AuthViewModel.shared

    var body: some Scene {
        WindowGroup {
            if authVM.isLoggedIn {
                ContentView()
            } else {
                LoginView()
            }
        }
    }
}
