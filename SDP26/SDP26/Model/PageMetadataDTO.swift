//
//  PageMetadataDTO.swift
//  SDP26
//
//  Created by José Luis Corral López on 4/12/25.
//

import Foundation

struct PageMetadata: Codable, Sendable {
    let total: Int
    let page: Int
    let per: Int
}
