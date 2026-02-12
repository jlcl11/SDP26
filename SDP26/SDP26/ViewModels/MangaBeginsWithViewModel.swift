//
//  MangaBeginsWithViewModel.swift
//  SDP26
//
//  Created by José Luis Corral López on 31/1/26.
//

import Foundation

@Observable
final class MangaBeginsWithViewModel {
    static let shared = MangaBeginsWithViewModel(dataSource: MangaBeginsWithDataSource(repository: NetworkRepository()))

    private(set) var mangas: [MangaDTO] = []
    private(set) var isLoading = false
    private let dataSource: MangaBeginsWithDataSource

    init(dataSource: MangaBeginsWithDataSource) {
        self.dataSource = dataSource
    }

    func search(name: String) async {
        guard !isLoading else { return }
        isLoading = true

        do {
            mangas = try await dataSource.fetch(name: name)
        } catch { }

        isLoading = false
    }

    func clear() {
        mangas = []
    }
}
