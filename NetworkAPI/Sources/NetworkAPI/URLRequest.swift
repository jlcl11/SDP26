//
//  URLRequest.swift
//  EmpleadosAPI
//
//  Created by Julio César Fernández Muñoz on 19/11/25.
//

import Foundation

public enum AuthType {
    case appToken
    case basic(email: String, pass: String)
    case bearer(token: String)
}

extension URLRequest {
    private static let appTokenValue = "sLGH38NhEJ0_anlIWwhsz1-LarClEohiAHQqayF0FY"

    public static func get(url: URL, token: String? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    public static func get(url: URL, auth: AuthType) -> URLRequest {
        var request = URLRequest(url: url)
        request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.applyAuth(auth)
        return request
    }

    public static func post<JSON>(url: URL, body: JSON, method: String = "POST") -> URLRequest where JSON: Codable {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        return request
    }

    public static func post<JSON>(url: URL, body: JSON, auth: AuthType, method: String = "POST") -> URLRequest where JSON: Codable {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        request.applyAuth(auth)
        return request
    }

    public static func post(url: URL, auth: AuthType) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.applyAuth(auth)
        return request
    }

    public static func delete(url: URL, auth: AuthType) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.applyAuth(auth)
        return request
    }

    private mutating func applyAuth(_ auth: AuthType) {
        switch auth {
        case .appToken:
            setValue(Self.appTokenValue, forHTTPHeaderField: "App-Token")
        case .basic(let email, let pass):
            let credentials = "\(email):\(pass)".data(using: .utf8)!.base64EncodedString()
            setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
        case .bearer(let token):
            setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
}
