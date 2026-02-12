//
//  AuthDataSource.swift
//  SDP26
//
//  Created by José Luis Corral López on 7/2/26.
//

import Foundation

actor AuthDataSource {
    private let repository: AuthenticationRepository
    private let storage: SecureStorage

    private var currentToken: String?
    private var tokenExpiration: Date?

    private let tokenKey = "com.mangavault.jwt.token"
    private let expirationKey = "com.mangavault.jwt.expiration"

    static let shared = AuthDataSource(repository: NetworkRepository(), storage: KeychainStorage())

    init(repository: AuthenticationRepository, storage: SecureStorage = KeychainStorage()) {
        self.repository = repository
        self.storage = storage
    }

    // MARK: - Authentication

    func login(email: String, password: String) async throws -> AuthResponse {
        let response = try await repository.login(email: email, password: password)
        await saveSession(token: response.token, expiresIn: response.expiresIn)
        return response
    }

    func register(email: String, password: String) async throws {
        let credentials = UserCredentials(email: email, password: password)
        try await repository.register(credentials: credentials)
    }

    func logout() async {
        await storage.delete(key: tokenKey)
        await storage.delete(key: expirationKey)
        currentToken = nil
        tokenExpiration = nil
    }

    // MARK: - Token Management

    func validToken() throws -> String {
        guard let token = currentToken,
              let expiration = tokenExpiration,
              Date() < expiration else {
            throw AuthError.tokenExpired
        }
        return token
    }

    func refreshTokenIfNeeded() async throws {
        guard let token = currentToken,
              let expiration = tokenExpiration else {
            throw AuthError.tokenExpired
        }

        // Refresh if less than 1 hour remaining
        if expiration.timeIntervalSinceNow < 3600 {
            let response = try await repository.refreshToken(token)
            await saveSession(token: response.token, expiresIn: response.expiresIn)
        }
    }

    func loadSession() async -> Bool {
        // Load token even if expired - we'll try to refresh it
        guard let tokenData = await storage.load(key: tokenKey),
              let token = String(data: tokenData, encoding: .utf8),
              let expiration = await loadExpiration() else {
            return false
        }

        currentToken = token
        tokenExpiration = expiration
        return true
    }

    func getMe() async throws -> UserResponse {
        let token = try validToken()
        return try await repository.getMe(token: token)
    }

    // MARK: - Private Helpers

    private func saveSession(token: String, expiresIn: Int) async {
        let expiration = Date().addingTimeInterval(TimeInterval(expiresIn))

        try? await storage.save(key: tokenKey, data: Data(token.utf8))
        if let expirationData = try? JSONEncoder().encode(expiration) {
            try? await storage.save(key: expirationKey, data: expirationData)
        }

        currentToken = token
        tokenExpiration = expiration
    }

    private func loadExpiration() async -> Date? {
        guard let data = await storage.load(key: expirationKey) else { return nil }
        return try? JSONDecoder().decode(Date.self, from: data)
    }
}
