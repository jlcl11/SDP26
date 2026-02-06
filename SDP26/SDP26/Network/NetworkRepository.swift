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

protocol MangaBeginsWithRepository: Sendable {
    func getMangaBeginsWith(name: String) async throws -> [MangaDTO]
}

protocol AuthorRepository: Sendable {
    func getAuthors(page: Int) async throws -> AuthorPageDTO
}

protocol AuthorByNameRepository: Sendable {
    func getAuthorByName(name: String) async throws -> [AuthorDTO]
}

protocol GenreRepository: Sendable {
    func getGenres() async throws -> [String]
}

protocol ThemeRepository: Sendable {
    func getThemes() async throws -> [String]
}

protocol DemographicRepository: Sendable {
    func getDemographics() async throws -> [String]
}

protocol CustomSearchRepository: Sendable {
    func customSearch(search: CustomSearch, page: Int) async throws -> MangaPageDTO
}

protocol MangasByAuthorRepository: Sendable {
    func getMangasByAuthor(authorID: UUID, page: Int) async throws -> MangaPageDTO
}

struct NetworkRepository: NetworkInteractor, MangaRepository, BestMangaRepository, MangaBeginsWithRepository, AuthorRepository, AuthorByNameRepository, GenreRepository, ThemeRepository, DemographicRepository, CustomSearchRepository, MangasByAuthorRepository, Sendable {
    func getAuthors(page: Int) async throws -> AuthorPageDTO {
        try await getJSON(.get(url: .getAuthors(page: page)), type: AuthorPageDTO.self)
    }

    func getAuthorByName(name: String) async throws -> [AuthorDTO] {
        try await getJSON(.get(url: .getAuthorByName(name: name)), type: [AuthorDTO].self)
    }

    func getMangas(page: Int) async throws -> MangaPageDTO {
        try await getJSON(.get(url: .getMangas(page: page)), type: MangaPageDTO.self)
    }

    func getBestMangas(page: Int) async throws -> MangaPageDTO {
        try await getJSON(.get(url: .getBestMangas(page: page)), type: MangaPageDTO.self)
    }

    func getMangaBeginsWith(name: String) async throws -> [MangaDTO] {
        try await getJSON(.get(url: .getMangaBeginsWith(name: name)), type: [MangaDTO].self)
    }

    func getGenres() async throws -> [String] {
        try await getJSON(.get(url: .getGenres), type: [String].self)
    }

    func getThemes() async throws -> [String] {
        try await getJSON(.get(url: .getThemes), type: [String].self)
    }

    func getDemographics() async throws -> [String] {
        try await getJSON(.get(url: .getDemographics), type: [String].self)
    }

    func customSearch(search: CustomSearch, page: Int) async throws -> MangaPageDTO {
        try await getJSON(.post(url: .customSearch(page: page), body: search), type: MangaPageDTO.self)
    }

    func getMangasByAuthor(authorID: UUID, page: Int) async throws -> MangaPageDTO {
        try await getJSON(.get(url: .getMangasByAuthor(page: page, authorID: authorID)), type: MangaPageDTO.self)
    }
}
