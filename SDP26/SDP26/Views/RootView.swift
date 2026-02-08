//
//  RootView.swift
//  SDP26
//
//  Created by José Luis Corral López on 8/2/26.
//

import SwiftUI

struct RootView: View {
    @State private var authVM = AuthViewModel.shared

    var body: some View {
        Group {
            if authVM.isLoggedIn {
                ContentView()
            } else {
                LoginView()
            }
        }
        .task {
            await authVM.refreshSessionIfNeeded()
        }
    }
}

#Preview {
    RootView()
}
