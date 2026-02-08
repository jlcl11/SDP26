//
//  CollectionVM.swift
//  SDP26
//
//  Created by José Luis Corral López on 8/2/26.
//

import Foundation

@Observable
final class CollectionVM {
    static let shared = CollectionVM(dataSource: CollectionDataSource.shared)

    private(set) var collection: [UserMangaCollectionDTO] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let dataSource: CollectionDataSource

    init(dataSource: CollectionDataSource) {
        self.dataSource = dataSource
    }

    // MARK: - Computed Properties

    var totalMangas: Int {
        collection.count
    }

    var completeCollectionCount: Int {
        collection.filter { $0.completeCollection }.count
    }

    var currentlyReadingCount: Int {
        collection.filter { $0.readingVolume != nil }.count
    }

    var ownedNotReadingCount: Int {
        collection.filter { !$0.completeCollection && $0.readingVolume == nil }.count
    }

    var totalVolumesOwned: Int {
        collection.reduce(0) { $0 + $1.volumesOwned.count }
    }

    var completeCollections: [UserMangaCollectionDTO] {
        collection.filter { $0.completeCollection }
    }

    var currentlyReading: [UserMangaCollectionDTO] {
        collection.filter { $0.readingVolume != nil }
    }

    var owned: [UserMangaCollectionDTO] {
        collection.filter { !$0.volumesOwned.isEmpty }
    }

    // MARK: - Public Methods

    func loadCollection() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            collection = try await dataSource.fetchCollection()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func getItem(for mangaId: Int) -> UserMangaCollectionDTO? {
        collection.first { $0.manga.id == mangaId }
    }

    func addOrUpdateManga(_ request: UserMangaCollectionRequest) async {
        do {
            try await dataSource.addOrUpdate(request)
            await loadCollection()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteManga(id: Int) async {
        do {
            try await dataSource.delete(mangaId: id)
            collection.removeAll { $0.manga.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func getMangaFromCollection(id: Int) async -> UserMangaCollectionDTO? {
        do {
            return try await dataSource.fetchManga(id: id)
        } catch {
            return nil
        }
    }
}
