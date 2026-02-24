//
//  MangaPageDTO.swift
//  SDP26
//
//  Created by José Luis Corral López on 4/12/25.
//

import Foundation

struct MangaPageDTO: Sendable, Codable {
    let items: [MangaDTO]
    let metadata: PageMetadata
}
