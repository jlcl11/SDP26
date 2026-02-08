//
//  AuthError.swift
//  SDP26
//
//  Created by José Luis Corral López on 7/2/26.
//

import Foundation

enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case tokenExpired
    case networkError(String)
    case registrationFailed(String)
    case emailAlreadyExists
    case weakPassword
    case invalidEmail

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .tokenExpired:
            return "Your session has expired. Please log in again."
        case .networkError(let message):
            return message
        case .registrationFailed(let message):
            return message
        case .emailAlreadyExists:
            return "An account with this email already exists"
        case .weakPassword:
            return "Password must be at least 8 characters"
        case .invalidEmail:
            return "Please enter a valid email address"
        }
    }
}
