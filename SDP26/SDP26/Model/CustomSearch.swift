//
//  CustomSearch.swift
//  SDP26
//
//  Created by José Luis Corral López on 28/1/26.
//

import Foundation

struct CustomSearch: Codable, Sendable {
    var searchTitle: String?
    var searchAuthorFirstName: String?
    var searchAuthorLastName: String?
    var searchGenres: [String]?
    var searchThemes: [String]?
    var searchDemographics: [String]?
    var searchContains: Bool    // false: beginsWith, true: contains
}
