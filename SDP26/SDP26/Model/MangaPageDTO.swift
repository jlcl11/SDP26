//
//  MangaPageDTO.swift
//  SDP26
//
//  Created by José Luis Corral López on 28/1/26.
//

import Foundation

struct MangaPageDTO: Sendable, Codable {
    let items: [MangaDTO]
    let metadata: PageMetadata
}
