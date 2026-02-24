//
//  MangaViewModel.swift
//  SDP26
//
//  Created by José Luis Corral López on 18/12/25.
//

import Foundation

@Observable
final class MangaViewModel {
    static let shared = MangaViewModel(
        dataSource: MangaDataSource(repository: NetworkRepository()),
        searchVM: MangaBeginsWithViewModel.shared,
        customSearchVM: CustomSearchViewModel.shared
    )

    private static let minimumSearchLength = 2

    private var allMangas: [MangaDTO] = []
    private(set) var isLoadingAll = false
    private let dataSource: MangaDataSource

    private let searchVM: MangaBeginsWithViewModel
    private let customSearchVM: CustomSearchViewModel

    var searchText: String = "" {
        didSet {
            handleSearchTextChange()
        }
    }

    private(set) var isCustomSearchActive = false
    var showSearchSheet = false

    var mangas: [MangaDTO] {
        if isCustomSearchActive {
            return customSearchVM.mangas
        } else if isSearching {
            return searchVM.mangas
        } else {
            return allMangas
        }
    }

    var isLoading: Bool {
        if isCustomSearchActive {
            return customSearchVM.isLoading
        } else if isSearching {
            return searchVM.isLoading
        } else {
            return isLoadingAll
        }
    }

    var isSearching: Bool {
        searchText.count >= Self.minimumSearchLength
    }

    var filterIconName: String {
        isCustomSearchActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle"
    }

    enum OverlayState {
        case loading
        case noFilterResults
        case noSearchResults(String)
        case noContent
        case none
    }

    var overlayState: OverlayState {
        if isLoading && mangas.isEmpty {
            return .loading
        } else if mangas.isEmpty {
            if isCustomSearchActive {
                return .noFilterResults
            } else if isSearching {
                return .noSearchResults(searchText)
            } else {
                return .noContent
            }
        }
        return .none
    }

    init(dataSource: MangaDataSource, searchVM: MangaBeginsWithViewModel, customSearchVM: CustomSearchViewModel) {
        self.dataSource = dataSource
        self.searchVM = searchVM
        self.customSearchVM = customSearchVM
    }

    func loadNextPage() async {
        guard !isLoadingAll else { return }
        isLoadingAll = true

        do {
            let newMangas = try await dataSource.fetchNextPage()
            allMangas.append(contentsOf: newMangas)
        } catch { }

        isLoadingAll = false
    }

    func loadNextPageIfNeeded(for manga: MangaDTO) async {
        guard manga.id == mangas.last?.id else { return }

        if isCustomSearchActive {
            await customSearchVM.loadNextPage()
        } else if !isSearching {
            await loadNextPage()
        }
    }

    func performCustomSearch(_ search: CustomSearch) async {
        isCustomSearchActive = true
        searchText = ""
        await customSearchVM.search(search)
    }

    func resetCustomSearch() async {
        isCustomSearchActive = false
        await customSearchVM.reset()
    }

    private func handleSearchTextChange() {
        if isSearching {
            isCustomSearchActive = false
            Task { await searchVM.search(name: searchText) }
        }
    }
}
