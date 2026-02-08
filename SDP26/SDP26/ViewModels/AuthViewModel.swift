//
//  AuthViewModel.swift
//  SDP26
//
//  Created by José Luis Corral López on 7/2/26.
//

import Foundation


@Observable
final class AuthViewModel {
    static let shared = AuthViewModel()

    private(set) var isLoggedIn = false
    private(set) var isLoading = false
    private(set) var currentUser: UserResponse?
    private(set) var tokenExpiration: Date?
    private(set) var error: AuthError?

    private let dataSource: AuthDataSource

    init(dataSource: AuthDataSource = AuthDataSource.shared) {
        self.dataSource = dataSource
        Task { await checkSession() }
    }

    // MARK: - Authentication

    func login(email: String, password: String) async {
        isLoading = true
        error = nil

        do {
            _ = try await dataSource.login(email: email, password: password)
            isLoggedIn = true
            await fetchCurrentUser()
        } catch let authError as AuthError {
            error = authError
        } catch {
            self.error = .networkError(error.localizedDescription)
        }

        isLoading = false
    }

    func register(email: String, password: String) async {
        isLoading = true
        error = nil

        do {
            try await dataSource.register(email: email, password: password)
        } catch let authError as AuthError {
            error = authError
        } catch {
            self.error = .networkError(error.localizedDescription)
        }

        isLoading = false
    }

    func logout() async {
        await dataSource.logout()
        isLoggedIn = false
        currentUser = nil
        tokenExpiration = nil
    }

    // MARK: - Session Management

    func refreshSessionIfNeeded() async {
        guard isLoggedIn else { return }

        do {
            try await dataSource.refreshTokenIfNeeded()
            if currentUser == nil {
                await fetchCurrentUser()
            }
        } catch {
            isLoggedIn = false
            currentUser = nil
        }
    }

    func fetchCurrentUser() async {
        do {
            currentUser = try await dataSource.getMe()
        } catch {
            currentUser = nil
        }
    }

    func validToken() async throws -> String {
        try await dataSource.validToken()
    }

    // MARK: - Computed Properties

    var tokenTimeRemaining: String? {
        guard let expiration = tokenExpiration else { return nil }
        let remaining = expiration.timeIntervalSinceNow
        guard remaining > 0 else { return "Expired" }

        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    // MARK: - Private

    private func checkSession() async {
        isLoggedIn = await dataSource.loadSession()

        if isLoggedIn {
            do {
                try await dataSource.refreshTokenIfNeeded()
                await fetchCurrentUser()
            } catch {
                isLoggedIn = false
            }
        }
    }
}
