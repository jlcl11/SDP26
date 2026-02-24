//
//  DemographicDTO.swift
//  SDP26
//
//  Created by José Luis Corral López on 3/12/25.
//

import Foundation

struct DemographicDTO: Sendable, Identifiable, Hashable, Codable {
    let id: UUID
    let demographic: Demographic
}
