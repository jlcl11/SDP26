//
//  KeychainStorage.swift
//  SDP26
//
//  Created by José Luis Corral López on 7/2/26.
//

import Foundation
import Security

struct KeychainStorage: SecureStorage {
    private let service = "com.mangavault.auth"

    func save(key: String, data: Data) async throws {
        print("[KeychainStorage] save() - key: \(key), data size: \(data.count) bytes")
        // Delete existing item first (upsert behavior)
        await delete(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        print("[KeychainStorage] save() - SecItemAdd status: \(status)")

        guard status == errSecSuccess else {
            print("[KeychainStorage] save() - FAILED with status: \(status)")
            throw KeychainError.saveFailed(status)
        }
        print("[KeychainStorage] save() - SUCCESS")
    }

    func load(key: String) async -> Data? {
        print("[KeychainStorage] load() - key: \(key)")
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        print("[KeychainStorage] load() - SecItemCopyMatching status: \(status)")

        guard status == errSecSuccess else {
            print("[KeychainStorage] load() - not found or error")
            return nil
        }

        let data = result as? Data
        print("[KeychainStorage] load() - SUCCESS, data size: \(data?.count ?? 0) bytes")
        return data
    }

    func delete(key: String) async {
        print("[KeychainStorage] delete() - key: \(key)")
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        print("[KeychainStorage] delete() - status: \(status)")
    }
}

enum KeychainError: Error, LocalizedError {
    case saveFailed(OSStatus)

    var errorDescription: String? {
        switch self {
        case .saveFailed(let status):
            return "Failed to save to Keychain: \(status)"
        }
    }
}
