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
    private(set) var isLoggedIn = false

    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }

    func performLogin() async {
        isLoading = true

        async let mangasTask: () = MangaViewModel.shared.loadNextPage()
        async let bestMangasTask: () = BestMangaViewModel.shared.loadNextPage()
        async let authorsTask: () = AuthorViewModel.shared.loadNextPage()
        async let genresTask: () = GenreViewModel.shared.load()
        async let themesTask: () = ThemeViewModel.shared.load()
        async let demographicsTask: () = DemographicViewModel.shared.load()

        _ = await (mangasTask, bestMangasTask, authorsTask, genresTask, themesTask, demographicsTask)

        isLoading = false
        isLoggedIn = true
    }
}
