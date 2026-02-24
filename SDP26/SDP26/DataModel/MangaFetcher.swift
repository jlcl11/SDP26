//
//  MangaFetcher.swift
//  SDP26
//
//  Created by José Luis Corral López on 15/12/25.
//

import SwiftUI

actor MangaDataSource {
    private let repository: MangaRepository
    private var currentPage = 1

    init(repository: MangaRepository) {
        self.repository = repository
    }

    func fetchNextPage() async throws -> [MangaDTO] {
        let mangaPage = try await repository.getMangas(page: currentPage)
        currentPage += 1
        return mangaPage.items
    }
}

actor BestMangaDataSource {
    private let repository: BestMangaRepository
    private var currentPage = 1

    init(repository: BestMangaRepository) {
        self.repository = repository
    }

    func fetchNextPage() async throws -> [MangaDTO] {
        let mangaPage = try await repository.getBestMangas(page: currentPage)
        currentPage += 1
        return mangaPage.items
    }
}

actor AuthorDataSource {
    private let repository: AuthorRepository
    private var currentPage = 1

    init(repository: AuthorRepository) {
        self.repository = repository
    }

    func fetchNextPage() async throws -> [AuthorDTO] {
        let authorPage = try await repository.getAuthors(page: currentPage)
        currentPage += 1
        return authorPage.items
    }
}

actor MangaBeginsWithDataSource {
    private let repository: MangaBeginsWithRepository

    init(repository: MangaBeginsWithRepository) {
        self.repository = repository
    }

    func fetch(name: String) async throws -> [MangaDTO] {
        try await repository.getMangaBeginsWith(name: name)
    }
}

actor AuthorByNameDataSource {
    private let repository: AuthorByNameRepository

    init(repository: AuthorByNameRepository) {
        self.repository = repository
    }

    func fetch(name: String) async throws -> [AuthorDTO] {
        try await repository.getAuthorByName(name: name)
    }
}

actor GenreDataSource {
    private let repository: GenreRepository

    init(repository: GenreRepository) {
        self.repository = repository
    }

    func fetch() async throws -> [String] {
        try await repository.getGenres()
    }
}

actor ThemeDataSource {
    private let repository: ThemeRepository

    init(repository: ThemeRepository) {
        self.repository = repository
    }

    func fetch() async throws -> [String] {
        try await repository.getThemes()
    }
}

actor DemographicDataSource {
    private let repository: DemographicRepository

    init(repository: DemographicRepository) {
        self.repository = repository
    }

    func fetch() async throws -> [String] {
        try await repository.getDemographics()
    }
}

actor CustomSearchDataSource {
    private let repository: CustomSearchRepository
    private var currentPage = 1

    init(repository: CustomSearchRepository) {
        self.repository = repository
    }

    func fetchNextPage(search: CustomSearch) async throws -> [MangaDTO] {
        let mangaPage = try await repository.customSearch(search: search, page: currentPage)
        currentPage += 1
        return mangaPage.items
    }

    func reset() {
        currentPage = 1
    }
}

actor MangasByAuthorDataSource {
    private let repository: MangasByAuthorRepository
    private var currentPage = 1

    init(repository: MangasByAuthorRepository) {
        self.repository = repository
    }

    func fetchNextPage(authorID: UUID) async throws -> [MangaDTO] {
        let mangaPage = try await repository.getMangasByAuthor(authorID: authorID, page: currentPage)
        currentPage += 1
        return mangaPage.items
    }

    func reset() {
        currentPage = 1
    }
}
