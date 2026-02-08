# Authentication Flow Documentation

This document describes how the app handles token checking on launch to determine whether to present the `AuthView` (login) or `MainTabView`.

## Overview

The app uses JWT (JSON Web Token) authentication with secure Keychain storage. On launch, it checks for a valid stored token and routes the user accordingly.

## Flow Diagram

```
App Launch
    ↓
SessionManager.init() → loadSession()
    ↓
Check Keychain for token + expiration
    ↓
├─ Valid token found → isLoggedIn = true  → MainTabView
└─ No token/expired  → isLoggedIn = false → AuthView
```

## Key Components

### 1. App Entry Point

**File:** `SDP26App.swift` (Lines 10-19)

The app initializes `SessionManager.shared` as a singleton and injects it into the SwiftUI environment:

```swift
@main
struct SDP26App: App {
    @State private var session = SessionManager.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(session)
        }
    }
}
```

### 2. Session Loading

**File:** `SessionManager.swift` (Lines 108-122)

When `SessionManager` is initialized, it calls `loadSession()` to check for an existing valid token:

```swift
private func loadSession() {
    guard let tokenData = storage.load(key: tokenKey),
          let token = String(data: tokenData, encoding: .utf8),
          let expiration = loadExpiration(),
          Date() < expiration else {
        isLoggedIn = false
        currentToken = nil
        tokenExpiration = nil
        return
    }

    currentToken = token
    tokenExpiration = expiration
    isLoggedIn = true
}
```

**Key checks performed:**
1. Token data exists in Keychain
2. Token can be decoded as UTF-8 string
3. Expiration date exists
4. Token has not expired (`Date() < expiration`)

If any check fails, `isLoggedIn` is set to `false`.

### 3. View Routing

**File:** `RootView.swift` (Lines 3-17)

The `RootView` observes the session state and routes accordingly:

```swift
struct RootView: View {
    @Environment(SessionManager.self) private var session

    var body: some View {
        Group {
            if session.isLoggedIn {
                MainTabView()
            } else {
                AuthView()
            }
        }
        .task {
            try? await session.refreshSessionIfNeeded()
        }
    }
}
```

The `.task` modifier also attempts to refresh the token if it's expiring soon (within 1 hour).

### 4. Secure Token Storage

**File:** `KeychainStorage.swift`

Tokens are stored securely in iOS Keychain using these keys:

| Key | Content |
|-----|---------|
| `com.mismangas.jwt.token` | JWT token string |
| `com.mismangas.jwt.expiration` | Expiration date (JSON-encoded) |

```swift
struct KeychainStorage: SecureStorage {
    func load(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        return status == errSecSuccess ? result as? Data : nil
    }
}
```

## Token Refresh

**File:** `SessionManager.swift` (Lines 73-94)

The app proactively refreshes tokens that expire within 1 hour:

```swift
@MainActor
func refreshSessionIfNeeded() async throws {
    guard let token = currentToken,
          let expiration = loadExpiration() else {
        throw NetworkError.tokenExpired
    }

    let timeRemaining = expiration.timeIntervalSinceNow

    if timeRemaining < 3600 {  // Less than 1 hour remaining
        let response = try await auth.refreshToken(token)
        saveSession(token: response.token, expiresIn: response.expiresIn)
    }

    if currentUser == nil {
        try await fetchCurrentUser()
    }
}
```

## Logout Flow

**File:** `SessionManager.swift` (Lines 55-62)

When the user logs out, all session data is cleared:

```swift
@MainActor
func logout() {
    storage.delete(key: tokenKey)
    storage.delete(key: expirationKey)
    currentToken = nil
    currentUser = nil
    tokenExpiration = nil
    isLoggedIn = false
}
```

The `@Observable` macro on `SessionManager` ensures the UI automatically updates, switching from `MainTabView` back to `AuthView`.

## Security Features

- **Keychain Storage:** Tokens are encrypted at the OS level
- **Expiration Validation:** Tokens are validated before use
- **Auto-Refresh:** Tokens are refreshed before expiration
- **Bearer Authentication:** All authenticated requests use Bearer tokens
- **Secure Logout:** All credentials are deleted on logout
