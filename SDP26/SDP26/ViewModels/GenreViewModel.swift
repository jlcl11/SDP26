//
//  GenreViewModel.swift
//  SDP26
//
//  Created by José Luis Corral López on 19/12/25.
//

import Foundation

@Observable
final class GenreViewModel {
    static let shared = GenreViewModel(dataSource: GenreDataSource(repository: NetworkRepository()))

    private(set) var genres: [String] = []
    private(set) var isLoading = false
    private let dataSource: GenreDataSource

    init(dataSource: GenreDataSource) {
        self.dataSource = dataSource
    }

    func load() async {
        guard !isLoading, genres.isEmpty else { return }
        isLoading = true

        do {
            genres = try await dataSource.fetch()
        } catch { }

        isLoading = false
    }
}
