//
//  UserMangaCollectionDTO.swift
//  SDP26
//
//  Created by José Luis Corral López on 11/12/25.
//

import Foundation

struct UserMangaCollectionDTO: Codable, Sendable, Identifiable {
    let completeCollection: Bool
    let id: String
    let volumesOwned: [Int]
    let manga: MangaDTO
    let readingVolume: Int?
}
