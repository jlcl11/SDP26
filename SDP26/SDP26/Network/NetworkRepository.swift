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

protocol AuthenticationRepository: Sendable {
    func login(email: String, password: String) async throws -> AuthResponse
    func register(credentials: UserCredentials) async throws
    func refreshToken(_ token: String) async throws -> AuthResponse
    func getMe(token: String) async throws -> UserResponse
}

protocol CollectionRepository: Sendable {
    func getCollection(token: String) async throws -> [UserMangaCollectionDTO]
    func getMangaFromCollection(id: Int, token: String) async throws -> UserMangaCollectionDTO
    func addOrUpdateManga(_ request: UserMangaCollectionRequest, token: String) async throws
    func deleteManga(id: Int, token: String) async throws
}

struct NetworkRepository: NetworkInteractor, MangaRepository, BestMangaRepository, MangaBeginsWithRepository, AuthorRepository, AuthorByNameRepository, GenreRepository, ThemeRepository, DemographicRepository, CustomSearchRepository, MangasByAuthorRepository, AuthenticationRepository, CollectionRepository, Sendable {
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

    // MARK: - Authentication

    func login(email: String, password: String) async throws -> AuthResponse {
        let request = URLRequest.post(url: .loginJWT, auth: .basic(email: email, pass: password))
        return try await getJSON(request, type: AuthResponse.self)
    }

    func register(credentials: UserCredentials) async throws {
        do {
            // Register requires App-Token header
            _ = try await getJSON(.post(url: .createUser, body: credentials, auth: .appToken), type: UserResponse.self)
        } catch {
            if case NetworkError.status(let code) = error {
                if code == 201 {
                    return // 201 is success for creation
                } else if code == 400 || code == 409 {
                    throw AuthError.emailAlreadyExists
                }
            }
            throw error
        }
    }

    func refreshToken(_ token: String) async throws -> AuthResponse {
        // Refresh requires Bearer token in header
        try await getJSON(.post(url: .refreshJWT, auth: .bearer(token: token)), type: AuthResponse.self)
    }

    func getMe(token: String) async throws -> UserResponse {
        try await getJSON(.get(url: .meJWT, token: token), type: UserResponse.self)
    }

    // MARK: - Collection

    func getCollection(token: String) async throws -> [UserMangaCollectionDTO] {
        try await getJSON(.get(url: .collection, auth: .bearer(token: token)), type: [UserMangaCollectionDTO].self)
    }

    func getMangaFromCollection(id: Int, token: String) async throws -> UserMangaCollectionDTO {
        try await getJSON(.get(url: .collectionManga(id: id), auth: .bearer(token: token)), type: UserMangaCollectionDTO.self)
    }

    func addOrUpdateManga(_ request: UserMangaCollectionRequest, token: String) async throws {
        do {
            // Server may return 200 (update) or 201 (create) - both are success
            try await postJSON(.post(url: .collection, body: request, auth: .bearer(token: token)), status: 200)
        } catch NetworkError.status(201) {
            // 201 Created is also success for new collection items
        } catch {
            throw error
        }
    }

    func deleteManga(id: Int, token: String) async throws {
        try await postJSON(.delete(url: .collectionManga(id: id), auth: .bearer(token: token)))
    }
}
