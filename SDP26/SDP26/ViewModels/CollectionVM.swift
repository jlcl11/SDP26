//
//  CollectionVM.swift
//  SDP26
//
//  Created by José Luis Corral López on 8/2/26.
//

import Foundation

@MainActor
@Observable
final class CollectionVM {
    static let shared = CollectionVM()

    private(set) var collection: [UserMangaCollectionDTO] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let repository: CollectionRepository
    private let authViewModel: AuthViewModel

    init(repository: CollectionRepository = NetworkRepository(),
         authViewModel: AuthViewModel = .shared) {
        self.repository = repository
        self.authViewModel = authViewModel
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
            let token = try await authViewModel.validToken()
            collection = try await repository.getCollection(token: token)
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
            let token = try await authViewModel.validToken()
            try await repository.addOrUpdateManga(request, token: token)
            await loadCollection()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteManga(id: Int) async {
        do {
            let token = try await authViewModel.validToken()
            try await repository.deleteManga(id: id, token: token)
            collection.removeAll { $0.manga.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func getMangaFromCollection(id: Int) async -> UserMangaCollectionDTO? {
        do {
            let token = try await authViewModel.validToken()
            return try await repository.getMangaFromCollection(id: id, token: token)
        } catch {
            return nil
        }
    }
}
