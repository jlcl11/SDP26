//
//  CustomSearch.swift
//  SDP26
//
//  Created by José Luis Corral López on 5/12/25.
//

import Foundation

struct CustomSearch: Codable, Sendable, Equatable {
    var searchTitle: String?
    var searchAuthorFirstName: String?
    var searchAuthorLastName: String?
    var searchGenres: [String]?
    var searchThemes: [String]?
    var searchDemographics: [String]?
    var searchContains: Bool    // false: beginsWith, true: contains
}
