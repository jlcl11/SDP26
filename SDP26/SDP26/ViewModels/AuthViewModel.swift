//
//  AuthViewModel.swift
//  SDP26
//
//  Created by José Luis Corral López on 7/2/26.
//

import Foundation
import Security


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
        isLoggedIn = KeychainHelper.hasValidSession()

        if isLoggedIn {
            Task {
                // Load token into Actor's memory, then fetch user
                _ = await dataSource.loadSession()
                await fetchCurrentUser()
            }
        }
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
        } catch let error as AuthError {
            // Only logout on actual auth errors
            if case .tokenExpired = error {
                await logout()
            } else if case .invalidCredentials = error {
                await logout()
            }
        } catch {
            // Network errors - don't logout, just leave currentUser as nil
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

}

// MARK: - Synchronous Keychain Helper

private enum KeychainHelper {
    private static let service = "com.mangavault.auth"
    private static let tokenKey = "com.mangavault.jwt.token"
    private static let expirationKey = "com.mangavault.jwt.expiration"

    @MainActor
    static func hasValidSession() -> Bool {
        guard let tokenData = load(key: tokenKey),
              let _ = String(data: tokenData, encoding: .utf8),
              let expiration = loadExpiration(),
              Date() < expiration else {
            return false
        }
        return true
    }

    private static func load(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        return status == errSecSuccess ? result as? Data : nil
    }

    private static func loadExpiration() -> Date? {
        guard let data = load(key: expirationKey) else { return nil }
        return try? JSONDecoder().decode(Date.self, from: data)
    }
}
