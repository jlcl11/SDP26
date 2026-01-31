//
//  AuthorViewModel.swift
//  SDP26
//
//  Created by José Luis Corral López on 31/1/26.
//

import Foundation

@Observable
final class AuthorViewModel {
    static let shared = AuthorViewModel(dataSource: AuthorDataSource(repository: NetworkRepository()))

    private(set) var authors: [AuthorDTO] = []
    private(set) var isLoading = false
    private let dataSource: AuthorDataSource

    init(dataSource: AuthorDataSource) {
        self.dataSource = dataSource
    }

    func loadNextPage() async {
        guard !isLoading else { return }
        isLoading = true

        do {
            let newAuthors = try await dataSource.fetchNextPage()
            authors.append(contentsOf: newAuthors)
        } catch {
            print("Error: \(error)")
        }

        isLoading = false
    }
}
