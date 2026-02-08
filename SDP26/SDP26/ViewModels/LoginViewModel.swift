//
//  LoginViewModel.swift
//  SDP26
//
//  Created by José Luis Corral López on 6/2/26.
//

import Foundation

@Observable
final class LoginViewModel {
    var email = ""
    var password = ""
    private(set) var isLoading = false
    private(set) var error: AuthError?

    private let authVM: AuthViewModel

    init(authVM: AuthViewModel = .shared) {
        self.authVM = authVM
    }

    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }

    func performLogin() async {
        print("[LoginViewModel] performLogin() called")
        print("[LoginViewModel] email: \(email), password length: \(password.count)")
        isLoading = true
        error = nil

        // Use AuthViewModel to perform login
        let success = await authVM.login(email: email, password: password)

        if let authError = authVM.error {
            error = authError
        } else if success {
            // Preload all data BEFORE navigating
            print("[LoginViewModel] preloading app data...")
            async let mangasTask: () = MangaViewModel.shared.loadNextPage()
            async let bestMangasTask: () = BestMangaViewModel.shared.loadNextPage()
            async let authorsTask: () = AuthorViewModel.shared.loadNextPage()
            async let collectionTask: () = CollectionVM.shared.loadCollection()

            _ = await (mangasTask, bestMangasTask, authorsTask, collectionTask)
            print("[LoginViewModel] app data preloaded")

            // NOW navigate to ContentView
            authVM.completeLogin()
        }

        isLoading = false
        print("[LoginViewModel] performLogin() finished - isLoggedIn: \(authVM.isLoggedIn), error: \(String(describing: error))")
    }

    func clearError() {
        error = nil
    }

    func preloadData() async {
        // Preload data that doesn't require authentication
        async let genresTask: () = GenreViewModel.shared.load()
        async let themesTask: () = ThemeViewModel.shared.load()
        async let demographicsTask: () = DemographicViewModel.shared.load()

        _ = await (genresTask, themesTask, demographicsTask)
    }
}
