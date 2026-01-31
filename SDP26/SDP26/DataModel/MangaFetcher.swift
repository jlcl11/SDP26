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
