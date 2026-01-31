//
//  MangaViewModel.swift
//  SDP26
//
//  Created by José Luis Corral López on 31/1/26.
//

import Foundation

@Observable
final class MangaViewModel {
    static let shared = MangaViewModel(dataSource: MangaDataSource(repository: NetworkRepository()))

    private(set) var mangas: [MangaDTO] = []
    private(set) var isLoading = false
    private let dataSource: MangaDataSource

    init(dataSource: MangaDataSource) {
        self.dataSource = dataSource
    }

    func loadNextPage() async {
        guard !isLoading else { return }
        isLoading = true

        do {
            let newMangas = try await dataSource.fetchNextPage()
            mangas.append(contentsOf: newMangas)
        } catch {
            print("Error: \(error)")
        }

        isLoading = false
    }
}
