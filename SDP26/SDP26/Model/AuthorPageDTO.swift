//
//  AuthorPageDTO.swift
//  SDP26
//
//  Created by José Luis Corral López on 2/12/25.
//

import Foundation

struct AuthorPageDTO: Sendable, Codable {
    let items: [AuthorDTO]
    let metadata: PageMetadata
}
