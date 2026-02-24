//
//  UsersCreate.swift
//  SDP26
//
//  Created by José Luis Corral López on 12/12/25.
//

import Foundation

struct UserCreate: Codable, Sendable {
    let email: String
    let password: String
}
