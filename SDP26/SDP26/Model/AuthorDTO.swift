//
//  AuthorDTO.swift
//  SDP26
//
//  Created by José Luis Corral López on 28/1/26.
//

import Foundation

struct AuthorDTO: Sendable, Codable, Identifiable {
    let id: UUID
    let firstName: String
    let lastName: String
    let role: AuthorRole

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
