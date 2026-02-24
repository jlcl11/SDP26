//
//  AuthorByNameViewModel.swift
//  SDP26
//
//  Created by José Luis Corral López on 23/12/25.
//

import Foundation

@Observable
final class AuthorByNameViewModel {
    static let shared = AuthorByNameViewModel(dataSource: AuthorByNameDataSource(repository: NetworkRepository()))

    private(set) var authors: [AuthorDTO] = []
    private(set) var isLoading = false
    private let dataSource: AuthorByNameDataSource

    init(dataSource: AuthorByNameDataSource) {
        self.dataSource = dataSource
    }

    func search(name: String) async {
        guard !isLoading else { return }
        isLoading = true

        do {
            authors = try await dataSource.fetch(name: name)
        } catch { }

        isLoading = false
    }
}
