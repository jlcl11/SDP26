//
//  MangaFetcher.swift
//  SDP26
//
//  Created by José Luis Corral López on 29/1/26.
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

actor GenreDataSource {
    private let repository: GenreRepository

    init(repository: GenreRepository) {
        self.repository = repository
    }

    func fetch() async throws -> [GenreDTO] {
        try await repository.getGenres()
    }
}

actor ThemeDataSource {
    private let repository: ThemeRepository

    init(repository: ThemeRepository) {
        self.repository = repository
    }

    func fetch() async throws -> [ThemeDTO] {
        try await repository.getThemes()
    }
}

actor DemographicDataSource {
    private let repository: DemographicRepository

    init(repository: DemographicRepository) {
        self.repository = repository
    }

    func fetch() async throws -> [DemographicDTO] {
        try await repository.getDemographics()
    }
}
