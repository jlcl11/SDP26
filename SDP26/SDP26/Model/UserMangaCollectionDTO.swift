//
//  UserMangaCollectionDTO.swift
//  SDP26
//
//  Created by José Luis Corral López on 28/1/26.
//

import Foundation

struct UserMangaCollectionDTO: Codable, Sendable, Identifiable {
    let completeCollection: Bool
    let id: String
    let volumesOwned: [Int]
    let manga: MangaDTO
    let readingVolume: Int?
}
