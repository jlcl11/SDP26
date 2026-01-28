//
//  UsersCreate.swift
//  SDP26
//
//  Created by José Luis Corral López on 28/1/26.
//

import Foundation

struct UserCreate: Codable, Sendable {
    let email: String
    let password: String
}
