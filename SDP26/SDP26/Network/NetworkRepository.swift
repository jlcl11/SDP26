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
        let url = URL.loginJWT
        print("[NetworkRepository] login() - URL: \(url)")
        let request = URLRequest.post(url: url, auth: .basic(email: email, pass: password))
        print("[NetworkRepository] login() - Request: \(request)")
        print("[NetworkRepository] login() - Using Basic Auth header")
        do {
            let response = try await getJSON(request, type: AuthResponse.self)
            print("[NetworkRepository] login() - SUCCESS: token=\(response.token.prefix(20))..., expiresIn=\(response.expiresIn)")
            return response
        } catch {
            print("[NetworkRepository] login() - FAILED: \(error)")
            if case NetworkError.status(let code) = error {
                print("[NetworkRepository] login() - HTTP Status Code: \(code)")
                if code == 401 {
                    print("[NetworkRepository] login() - 401 = Invalid credentials (wrong email/password or user not registered)")
                }
            }
            throw error
        }
    }

    func register(credentials: UserCredentials) async throws {
        print("[NetworkRepository] register() - URL: \(URL.createUser)")
        print("[NetworkRepository] register() - email: \(credentials.email)")
        do {
            // Register requires App-Token header
            _ = try await getJSON(.post(url: .createUser, body: credentials, auth: .appToken), type: UserResponse.self)
            print("[NetworkRepository] register() - SUCCESS")
        } catch {
            print("[NetworkRepository] register() - FAILED: \(error)")
            if case NetworkError.status(let code) = error {
                print("[NetworkRepository] register() - HTTP Status Code: \(code)")
                if code == 201 {
                    print("[NetworkRepository] register() - 201 = Created successfully (this is OK)")
                    return // 201 is success for creation
                } else if code == 400 || code == 409 {
                    print("[NetworkRepository] register() - \(code) = Email already exists")
                    throw AuthError.emailAlreadyExists
                }
            }
            throw error
        }
    }

    func refreshToken(_ token: String) async throws -> AuthResponse {
        print("[NetworkRepository] refreshToken() - URL: \(URL.refreshJWT)")
        do {
            // Refresh requires Bearer token in header
            let response = try await getJSON(.post(url: .refreshJWT, auth: .bearer(token: token)), type: AuthResponse.self)
            print("[NetworkRepository] refreshToken() - SUCCESS")
            return response
        } catch {
            print("[NetworkRepository] refreshToken() - FAILED: \(error)")
            throw error
        }
    }

    func getMe(token: String) async throws -> UserResponse {
        print("[NetworkRepository] getMe() - URL: \(URL.meJWT)")
        do {
            let response = try await getJSON(.get(url: .meJWT, token: token), type: UserResponse.self)
            print("[NetworkRepository] getMe() - SUCCESS: \(response)")
            return response
        } catch {
            print("[NetworkRepository] getMe() - FAILED: \(error)")
            throw error
        }
    }

    // MARK: - Collection

    func getCollection(token: String) async throws -> [UserMangaCollectionDTO] {
        print("[NetworkRepository] getCollection() - URL: \(URL.collection)")
        do {
            let response = try await getJSON(.get(url: .collection, auth: .bearer(token: token)), type: [UserMangaCollectionDTO].self)
            print("[NetworkRepository] getCollection() - SUCCESS: \(response.count) items")
            return response
        } catch {
            print("[NetworkRepository] getCollection() - FAILED: \(error)")
            throw error
        }
    }

    func getMangaFromCollection(id: Int, token: String) async throws -> UserMangaCollectionDTO {
        let url = URL.collectionManga(id: id)
        print("[NetworkRepository] getMangaFromCollection() - URL: \(url)")
        do {
            let response = try await getJSON(.get(url: url, auth: .bearer(token: token)), type: UserMangaCollectionDTO.self)
            print("[NetworkRepository] getMangaFromCollection() - SUCCESS")
            return response
        } catch {
            print("[NetworkRepository] getMangaFromCollection() - FAILED: \(error)")
            throw error
        }
    }

    func addOrUpdateManga(_ request: UserMangaCollectionRequest, token: String) async throws {
        print("[NetworkRepository] addOrUpdateManga() - URL: \(URL.collection), manga: \(request.manga)")
        do {
            // Server may return 200 (update) or 201 (create) - both are success
            try await postJSON(.post(url: .collection, body: request, auth: .bearer(token: token)), status: 200)
            print("[NetworkRepository] addOrUpdateManga() - SUCCESS (200)")
        } catch NetworkError.status(201) {
            // 201 Created is also success for new collection items
            print("[NetworkRepository] addOrUpdateManga() - SUCCESS (201)")
        } catch {
            print("[NetworkRepository] addOrUpdateManga() - FAILED: \(error)")
            throw error
        }
    }

    func deleteManga(id: Int, token: String) async throws {
        let url = URL.collectionManga(id: id)
        print("[NetworkRepository] deleteManga() - URL: \(url)")
        do {
            try await postJSON(.delete(url: url, auth: .bearer(token: token)))
            print("[NetworkRepository] deleteManga() - SUCCESS")
        } catch {
            print("[NetworkRepository] deleteManga() - FAILED: \(error)")
            throw error
        }
    }
}
