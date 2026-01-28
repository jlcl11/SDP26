//
//  UserResponse.swift
//  SDP26
//
//  Created by José Luis Corral López on 28/1/26.
//

import Foundation

struct UserResponse: Codable, Sendable {
    let id: UUID
    let email: String
    let role: String         
    let isActive: Bool
    let isAdmin: Bool
}
