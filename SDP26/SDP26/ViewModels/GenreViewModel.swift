//
//  GenreViewModel.swift
//  SDP26
//
//  Created by José Luis Corral López on 31/1/26.
//

import Foundation

@Observable
final class GenreViewModel {
    static let shared = GenreViewModel(dataSource: GenreDataSource(repository: NetworkRepository()))

    private(set) var genres: [GenreDTO] = []
    private(set) var isLoading = false
    private let dataSource: GenreDataSource

    init(dataSource: GenreDataSource) {
        self.dataSource = dataSource
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true

        do {
            genres = try await dataSource.fetch()
        } catch {
            print("Error: \(error)")
        }

        isLoading = false
    }
}
