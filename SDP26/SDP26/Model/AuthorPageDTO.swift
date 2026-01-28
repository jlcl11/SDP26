//
//  AuthorPageDTO.swift
//  SDP26
//
//  Created by José Luis Corral López on 28/1/26.
//

import Foundation

struct AuthorPageDTO: Sendable {
    let items: [AuthorDTO]
    let metadata: PageMetadata
}
