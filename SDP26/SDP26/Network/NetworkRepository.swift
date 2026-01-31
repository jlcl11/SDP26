//
//  NetworkRepository.swift
//  SDP26
//
//  Created by José Luis Corral López on 29/1/26.
//

import Foundation
import NetworkAPI

protocol MangaRepository: Sendable {
    func getMangas(page: Int) async throws -> MangaPageDTO
}

protocol BestMangaRepository: Sendable {
    func getBestMangas(page: Int) async throws -> MangaPageDTO
}

protocol AuthorRepository: Sendable {
    func getAuthors(page: Int) async throws -> AuthorPageDTO
}

protocol GenreRepository: Sendable {
    func getGenres() async throws -> [GenreDTO]
}

protocol ThemeRepository: Sendable {
    func getThemes() async throws -> [ThemeDTO]
}

protocol DemographicRepository: Sendable {
    func getDemographics() async throws -> [DemographicDTO]
}

struct NetworkRepository: NetworkInteractor, MangaRepository, BestMangaRepository, AuthorRepository, GenreRepository, ThemeRepository, DemographicRepository, Sendable {
    func getAuthors(page: Int) async throws -> AuthorPageDTO {
        try await getJSON(.get(url: .getAuthors(page: page)), type: AuthorPageDTO.self)
    }

    func getMangas(page: Int) async throws -> MangaPageDTO {
        try await getJSON(.get(url: .getMangas(page: page)), type: MangaPageDTO.self)
    }

    func getBestMangas(page: Int) async throws -> MangaPageDTO {
        try await getJSON(.get(url: .getBestMangas(page: page)), type: MangaPageDTO.self)
    }

    func getGenres() async throws -> [GenreDTO] {
        try await getJSON(.get(url: .getGenres), type: [GenreDTO].self)
    }

    func getThemes() async throws -> [ThemeDTO] {
        try await getJSON(.get(url: .getThemes), type: [ThemeDTO].self)
    }

    func getDemographics() async throws -> [DemographicDTO] {
        try await getJSON(.get(url: .getDemographics), type: [DemographicDTO].self)
    }
}
