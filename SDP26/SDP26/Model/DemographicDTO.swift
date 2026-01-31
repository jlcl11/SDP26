//
//  DemographicDTO.swift
//  SDP26
//
//  Created by José Luis Corral López on 28/1/26.
//

import Foundation

struct DemographicDTO: Sendable, Identifiable, Hashable, Codable {
    let id: UUID
    let demographic: Demographic
}
