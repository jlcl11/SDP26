//
//  CollectionVM.swift
//  SDP26
//
//  Created by José Luis Corral López on 8/2/26.
//

import Foundation
import SwiftData
import NetworkAPI
import WidgetKit

@Observable
final class CollectionVM {
    static let shared = CollectionVM(dataSource: CollectionDataSource.shared)

    private(set) var collection: [UserMangaCollectionDTO] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var isOffline = false
    private(set) var pendingChangesCount = 0
    private(set) var isSyncing = false

    private let dataSource: CollectionDataSource
    private var dataContainer: CollectionDataContainer?

    init(dataSource: CollectionDataSource) {
        self.dataSource = dataSource
    }

    // MARK: - SwiftData Setup

    /// Configures the ViewModel with a ModelContainer for local persistence
    func configure(with modelContainer: ModelContainer) {
        self.dataContainer = CollectionDataContainer(modelContainer: modelContainer)
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

    /// Loads collection with online-first strategy (cloud is source of truth):
    /// 1. Fetch from API (download cloud)
    /// 2. Sync to local storage (overwrite local)
    /// 3. Push any pending offline changes to API (upload pending)
    /// 4. Fetch again to get final state (cloud = local)
    /// 5. If offline, fall back to local cache
    func loadCollection() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        isOffline = false

        do {
            // Step 1: Descargar nube - Fetch from API (cloud is source of truth)
            var apiCollection = try await dataSource.fetchCollection()

            // Step 2: Sobrescribir local - Sync to local storage
            await syncToLocalStorage(apiCollection)

            // Step 3: Update in-memory collection
            collection = apiCollection

            // Step 3.5: Pre-cache first 5 images for widget preview (sync)
            await preCacheImagesForWidget(Array(apiCollection.prefix(5)))
            WidgetDataManager.shared.refreshWidget()

            // Step 4: Subir pendientes - Push any pending changes to API
            let hadPendingChanges = await hasPendingChanges()
            if hadPendingChanges {
                await syncPendingChanges()

                // Step 5: Volver a descargar - Fetch again to get final merged state
                // This ensures local reflects the uploaded changes
                apiCollection = try await dataSource.fetchCollection()
                await syncToLocalStorage(apiCollection)
                collection = apiCollection
                await preCacheImagesForWidget(Array(apiCollection.prefix(5)))
                WidgetDataManager.shared.refreshWidget()
            }

            // Step 6: Pre-cache remaining images for offline viewing (background task)
            Task.detached(priority: .background) { [collection] in
                await self.preCacheImages(for: collection)
            }

        } catch {
            // API failed - fall back to local cache
            isOffline = true
            await loadFromLocalStorage()

            if collection.isEmpty {
                errorMessage = "No internet connection and no cached data"
            }
        }

        // Update pending count
        await updatePendingCount()

        isLoading = false
    }

    /// Checks if there are pending changes
    private func hasPendingChanges() async -> Bool {
        guard let dataContainer = dataContainer else { return false }
        do {
            return try await dataContainer.pendingChangesCount() > 0
        } catch {
            return false
        }
    }

    /// Syncs API data to local SwiftData storage
    private func syncToLocalStorage(_ apiCollection: [UserMangaCollectionDTO]) async {
        guard let dataContainer = dataContainer else { return }

        do {
            // Sync API data to local storage
            try await dataContainer.syncCollection(from: apiCollection)

            // Remove items that are no longer in the API response
            let currentIds = Set(apiCollection.map { $0.id })
            try await dataContainer.removeStaleItems(currentIds: currentIds)
        } catch {
            print("Failed to sync to local storage: \(error)")
        }
    }

    /// Loads collection from local SwiftData (fallback for offline)
    private func loadFromLocalStorage() async {
        guard let dataContainer = dataContainer else { return }

        do {
            let localItems = try await dataContainer.fetchLocalCollection()
            collection = localItems
            WidgetDataManager.shared.refreshWidget()
        } catch {
            print("Failed to load from local storage: \(error)")
        }
    }

    func getItem(for mangaId: Int) -> UserMangaCollectionDTO? {
        collection.first { $0.manga.id == mangaId }
    }

    /// Gets item from local storage (for offline access)
    func getLocalItem(for mangaId: Int) async -> UserMangaCollectionDTO? {
        guard let dataContainer = dataContainer else { return nil }

        do {
            return try await dataContainer.fetchItem(mangaId: mangaId)
        } catch {
            return nil
        }
    }

    func addOrUpdateManga(_ request: UserMangaCollectionRequest) async {
        do {
            // Try API first (online-first)
            try await dataSource.addOrUpdate(request)

            // Success - reload to get updated data and sync locally
            await loadCollection()

        } catch {
            // API failed - save locally and queue for later sync
            await saveOfflineChange(request)
        }
    }

    func deleteManga(id: Int) async {
        do {
            // Try API first (online-first)
            try await dataSource.delete(mangaId: id)

            // Success - delete from local storage
            if let dataContainer = dataContainer {
                try await dataContainer.deleteItem(mangaId: id)
            }

            // Remove from in-memory collection
            collection.removeAll { $0.manga.id == id }
            WidgetDataManager.shared.refreshWidget()

        } catch {
            // API failed - queue delete for later and update locally
            await queueOfflineDelete(mangaId: id)
        }
    }

    // MARK: - Offline Support

    /// Saves a change locally when offline and queues it for API sync
    private func saveOfflineChange(_ request: UserMangaCollectionRequest) async {
        guard let dataContainer = dataContainer else {
            errorMessage = "Cannot save offline - storage not configured"
            return
        }

        do {
            // Update local storage immediately
            try await dataContainer.updateLocalItem(
                mangaId: request.manga,
                volumesOwned: request.volumesOwned,
                readingVolume: request.readingVolume,
                completeCollection: request.completeCollection
            )

            // Queue the change for API sync when back online
            try await dataContainer.queuePendingChange(request)

            // Update in-memory collection
            if let index = collection.firstIndex(where: { $0.manga.id == request.manga }) {
                let updated = collection[index]
                // Create updated DTO (keeping manga data, updating collection data)
                collection[index] = UserMangaCollectionDTO(
                    completeCollection: request.completeCollection,
                    id: updated.id,
                    volumesOwned: request.volumesOwned,
                    manga: updated.manga,
                    readingVolume: request.readingVolume
                )
            }
            WidgetDataManager.shared.refreshWidget()

            // Update pending count
            await updatePendingCount()

            isOffline = true

        } catch {
            errorMessage = "Failed to save offline: \(error.localizedDescription)"
        }
    }

    /// Queues a delete operation when offline
    private func queueOfflineDelete(mangaId: Int) async {
        guard let dataContainer = dataContainer else {
            errorMessage = "Cannot save offline - storage not configured"
            return
        }

        do {
            // Queue the delete for API sync
            try await dataContainer.queuePendingDelete(mangaId: mangaId)

            // Delete from local storage
            try await dataContainer.deleteItem(mangaId: mangaId)

            // Remove from in-memory collection
            collection.removeAll { $0.manga.id == mangaId }
            WidgetDataManager.shared.refreshWidget()

            // Update pending count
            await updatePendingCount()

            isOffline = true

        } catch {
            errorMessage = "Failed to queue delete: \(error.localizedDescription)"
        }
    }

    /// Syncs all pending changes to API
    func syncPendingChanges() async {
        guard let dataContainer = dataContainer else { return }

        do {
            let pendingChanges = try await dataContainer.fetchPendingChanges()
            guard !pendingChanges.isEmpty else { return }

            isSyncing = true

            for change in pendingChanges {
                do {
                    if change.isDelete {
                        try await dataSource.delete(mangaId: change.mangaId)
                    } else {
                        try await dataSource.addOrUpdate(change.toRequest())
                    }

                    // Remove from pending queue after successful sync
                    try await dataContainer.removePendingChange(mangaId: change.mangaId)

                } catch {
                    // Keep in queue if sync fails - will retry next time
                    print("Failed to sync change for manga \(change.mangaId): \(error)")
                }
            }

            isSyncing = false

        } catch {
            print("Failed to fetch pending changes: \(error)")
            isSyncing = false
        }
    }

    /// Updates the pending changes count
    private func updatePendingCount() async {
        guard let dataContainer = dataContainer else { return }

        do {
            pendingChangesCount = try await dataContainer.pendingChangesCount()
        } catch {
            pendingChangesCount = 0
        }
    }

    func getMangaFromCollection(id: Int) async -> UserMangaCollectionDTO? {
        // Online-first: Try API first
        do {
            let item = try await dataSource.fetchManga(id: id)
            // Sync single item to local storage
            if let dataContainer = dataContainer {
                try await dataContainer.syncItem(item)
            }
            return item
        } catch {
            // Fall back to local cache if offline
            return await getLocalItem(for: id)
        }
    }

    /// Clears all local collection data (useful for logout)
    func clearLocalData() async {
        guard let dataContainer = dataContainer else { return }

        do {
            try await dataContainer.deleteAllItems()
            collection = []
            WidgetDataManager.shared.clearWidgetData()
        } catch {
            print("Failed to clear local data: \(error)")
        }
    }

    // MARK: - Image Pre-Caching

    /// Pre-caches images for widget preview (runs synchronously before widget refresh)
    private func preCacheImagesForWidget(_ items: [UserMangaCollectionDTO]) async {
        for item in items {
            guard let url = item.manga.imageURL else { continue }

            // Skip if already in shared cache
            if SharedImageCache.shared.loadImage(for: url) != nil {
                continue
            }

            // Download and save to shared cache
            if let image = await ImageDownloader.shared.loadImage(url: url) {
                await SharedImageCache.shared.saveImage(image, for: url)
            }
        }
    }

    /// Pre-downloads and caches images for offline viewing and widget
    private func preCacheImages(for items: [UserMangaCollectionDTO]) async {
        var didCacheNewImages = false

        for item in items {
            guard let url = item.manga.imageURL else { continue }

            // Check if already cached in shared cache (for widget)
            if SharedImageCache.shared.loadImage(for: url) != nil {
                continue // Already cached
            }

            // Download and cache
            if let image = await ImageDownloader.shared.loadImage(url: url) {
                // Also save to shared cache for widget access
                await SharedImageCache.shared.saveImage(image, for: url)
                didCacheNewImages = true
            }
        }

        // Refresh widget again after images are cached
        if didCacheNewImages {
            await MainActor.run {
                WidgetDataManager.shared.refreshWidget()
            }
        }
    }
}
