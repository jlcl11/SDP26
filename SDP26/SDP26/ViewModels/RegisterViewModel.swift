//
//  RegisterViewModel.swift
//  SDP26
//
//  Created by José Luis Corral López on 6/2/26.
//

import Foundation

@Observable
final class RegisterViewModel {
    var email = ""
    var password = ""
    var confirmPassword = ""
    private(set) var isLoading = false
    private(set) var isRegistered = false

    var passwordsMatch: Bool {
        !password.isEmpty && password == confirmPassword
    }

    var isFormValid: Bool {
        !email.isEmpty && email.contains("@") && password.count >= 8 && passwordsMatch
    }

    var hasMinimumLength: Bool {
        password.count >= 8
    }

    func performRegister() async {
        isLoading = true

        // TODO: Implement actual registration
        try? await Task.sleep(for: .seconds(1))

        isLoading = false
        isRegistered = true
    }
}
