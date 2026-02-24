//
//  AuthorDTO.swift
//  SDP26
//
//  Created by José Luis Corral López on 2/12/25.
//

import Foundation

struct AuthorDTO: Sendable, Codable, Identifiable, Hashable {
    let id: UUID
    let firstName: String
    let lastName: String
    let role: AuthorRole

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
