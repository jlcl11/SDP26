//
//  UserMangaCollectionRequest.swift
//  SDP26
//
//  Created by José Luis Corral López on 11/12/25.
//

import Foundation

struct UserMangaCollectionRequest: Codable, Sendable {
    let volumesOwned: [Int]
    let completeCollection: Bool
    let manga: Int
    let readingVolume: Int?
}
