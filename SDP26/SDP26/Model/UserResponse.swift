//
//  UserResponse.swift
//  SDP26
//
//  Created by José Luis Corral López on 12/12/25.
//

import Foundation

struct UserResponse: Codable, Sendable {
    let id: UUID
    let email: String
    let role: String         
    let isActive: Bool
    let isAdmin: Bool
}
