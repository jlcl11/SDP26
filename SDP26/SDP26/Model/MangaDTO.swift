//
//  MangaDTO.swift
//  SDP26
//
//  Created by José Luis Corral López on 2/12/25.
//

import Foundation

struct MangaDTO: Sendable, Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let titleEnglish: String?
    let titleJapanese: String?
    let status: MangaStatus
    let startDate: Date?
    let endDate: Date?
    let chapters: Int?
    let volumes: Int?
    let score: Double
    let mainPicture: String?
    let sypnosis: String?
    let background: String?
    let url: String?
    let authors: [AuthorDTO]
    let genres: [GenreDTO]
    let themes: [ThemeDTO]
    let demographics: [DemographicDTO]

    var imageURL: URL? {
        guard let picture = mainPicture else { return nil }
        return URL(string: picture.trimmingCharacters(in: CharacterSet(charactersIn: "\"")))
    }
}
