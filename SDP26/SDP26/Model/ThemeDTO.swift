//
//  ThemeDTO.swift
//  SDP26
//
//  Created by José Luis Corral López on 3/12/25.
//

import Foundation

struct ThemeDTO: Codable, Sendable, Identifiable, Hashable {
    let id: UUID
    let theme: String
}
