//
//  GenreDTO.swift
//  SDP26
//
//  Created by José Luis Corral López on 28/1/26.
//

import Foundation

struct GenreDTO: Codable, Sendable, Identifiable, Hashable {
    let id: UUID
    let genre: String
}
