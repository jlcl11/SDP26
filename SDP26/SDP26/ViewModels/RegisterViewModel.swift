//
//  RegisterViewModel.swift
//  SDP26
//
//  Created by José Luis Corral López on 6/2/26.
//

import Foundation

@MainActor
@Observable
final class RegisterViewModel {
    var email = ""
    var password = ""
    var confirmPassword = ""
    private(set) var isLoading = false
    private(set) var isRegistered = false
    private(set) var error: AuthError?

    private let authVM: AuthViewModel

    init(authVM: AuthViewModel = .shared) {
        self.authVM = authVM
    }

    var passwordsMatch: Bool {
        !password.isEmpty && password == confirmPassword
    }

    var isFormValid: Bool {
        !email.isEmpty && email.contains("@") && password.count >= 8 && passwordsMatch
    }

    var hasMinimumLength: Bool {
        password.count >= 8
    }

    var emailAlreadyExists: Bool {
        if case .emailAlreadyExists = error {
            return true
        }
        return false
    }

    func performRegister() async {
        isLoading = true
        error = nil

        await authVM.register(email: email, password: password)

        if let authError = authVM.error {
            error = authError
        } else {
            isRegistered = true
        }

        isLoading = false
    }

    func clearError() {
        error = nil
    }
}
