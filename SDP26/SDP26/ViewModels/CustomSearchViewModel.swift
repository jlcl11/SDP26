//
//  CustomSearchViewModel.swift
//  SDP26
//
//  Created by José Luis Corral López on 31/1/26.
//

import Foundation

@Observable
final class CustomSearchViewModel {
    static let shared = CustomSearchViewModel(dataSource: CustomSearchDataSource(repository: NetworkRepository()))

    private(set) var mangas: [MangaDTO] = []
    private(set) var isLoading = false
    private var currentSearch: CustomSearch?
    private let dataSource: CustomSearchDataSource

    init(dataSource: CustomSearchDataSource) {
        self.dataSource = dataSource
    }

    func search(_ search: CustomSearch) async {
        guard !isLoading else { return }

        if search != currentSearch {
            mangas = []
            currentSearch = search
            await dataSource.reset()
        }

        isLoading = true

        do {
            let newMangas = try await dataSource.fetchNextPage(search: search)
            mangas.append(contentsOf: newMangas)
        } catch { }

        isLoading = false
    }

    func loadNextPage() async {
        guard let search = currentSearch else { return }
        await self.search(search)
    }

    func reset() async {
        mangas = []
        currentSearch = nil
        await dataSource.reset()
    }
}
