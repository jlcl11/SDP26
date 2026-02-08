//
//  CollectionDataSource.swift
//  SDP26
//
//  Created by José Luis Corral López on 8/2/26.
//

import Foundation

actor CollectionDataSource {
    private let repository: CollectionRepository
    private let authDataSource: AuthDataSource

    static let shared = CollectionDataSource(
        repository: NetworkRepository(),
        authDataSource: AuthDataSource.shared
    )

    init(repository: CollectionRepository, authDataSource: AuthDataSource) {
        self.repository = repository
        self.authDataSource = authDataSource
    }

    func fetchCollection() async throws -> [UserMangaCollectionDTO] {
        let token = try await authDataSource.validToken()
        return try await repository.getCollection(token: token)
    }

    func fetchManga(id: Int) async throws -> UserMangaCollectionDTO {
        let token = try await authDataSource.validToken()
        return try await repository.getMangaFromCollection(id: id, token: token)
    }

    func addOrUpdate(_ request: UserMangaCollectionRequest) async throws {
        let token = try await authDataSource.validToken()
        try await repository.addOrUpdateManga(request, token: token)
    }

    func delete(mangaId: Int) async throws {
        let token = try await authDataSource.validToken()
        try await repository.deleteManga(id: mangaId, token: token)
    }
}
