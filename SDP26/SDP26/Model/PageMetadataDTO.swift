//
//  PageMetadataDTO.swift
//  SDP26
//
//  Created by José Luis Corral López on 28/1/26.
//

import Foundation

struct PageMetadata: Codable, Sendable {
    let total: Int
    let page: Int
    let per: Int
}
