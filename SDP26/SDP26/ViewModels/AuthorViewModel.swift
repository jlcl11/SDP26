//
//  AuthorViewModel.swift
//  SDP26
//
//  Created by José Luis Corral López on 31/1/26.
//

import Foundation

@Observable
final class AuthorViewModel {
    static let shared = AuthorViewModel(
        dataSource: AuthorDataSource(repository: NetworkRepository()),
        searchVM: AuthorByNameViewModel.shared
    )

    private static let minimumSearchLength = 2

    private var allAuthors: [AuthorDTO] = []
    private(set) var isLoadingAll = false
    private let dataSource: AuthorDataSource

    private let searchVM: AuthorByNameViewModel

    var searchText: String = "" {
        didSet {
            handleSearchTextChange()
        }
    }

    var authors: [AuthorDTO] {
        isSearching ? searchVM.authors : allAuthors
    }

    var isLoading: Bool {
        isSearching ? searchVM.isLoading : isLoadingAll
    }

    var isSearching: Bool {
        searchText.count >= Self.minimumSearchLength
    }

    init(dataSource: AuthorDataSource, searchVM: AuthorByNameViewModel) {
        self.dataSource = dataSource
        self.searchVM = searchVM
    }

    func loadNextPage() async {
        guard !isLoadingAll else { return }
        isLoadingAll = true

        do {
            let newAuthors = try await dataSource.fetchNextPage()
            allAuthors.append(contentsOf: newAuthors)
        } catch { }

        isLoadingAll = false
    }

    func loadNextPageIfNeeded(for author: AuthorDTO) async {
        guard !isSearching, author.id == authors.last?.id else { return }
        await loadNextPage()
    }

    private func handleSearchTextChange() {
        if isSearching {
            Task { await searchVM.search(name: searchText) }
        }
    }
}
