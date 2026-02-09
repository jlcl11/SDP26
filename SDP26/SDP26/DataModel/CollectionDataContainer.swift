//
//  CollectionDataContainer.swift
//  SDP26
//
//  SwiftData ModelActor for thread-safe collection persistence.
//  Handles syncing between API and local storage.
//

import Foundation
import SwiftData

@ModelActor
actor CollectionDataContainer {

    // MARK: - Sync from API to Local Storage

    /// Syncs the collection from API response to local SwiftData storage.
    /// Uses upsert pattern: updates existing records or inserts new ones.
    func syncCollection(from dtos: [UserMangaCollectionDTO]) throws {
        for dto in dtos {
            let collectionId = dto.id

            // Check if this collection entry already exists
            var fetch = FetchDescriptor<MangaCollectionModel>(
                predicate: #Predicate { $0.id == collectionId }
            )
            fetch.fetchLimit = 1

            let existing = try modelContext.fetch(fetch)

            if let existingItem = existing.first {
                // Update existing record
                updateModel(existingItem, from: dto)
            } else {
                // Insert new record
                let newItem = MangaCollectionModel(from: dto)
                modelContext.insert(newItem)
            }
        }

        // Save changes
        if modelContext.hasChanges {
            try modelContext.save()
        }
    }

    /// Syncs a single collection item
    func syncItem(_ dto: UserMangaCollectionDTO) throws {
        let collectionId = dto.id

        var fetch = FetchDescriptor<MangaCollectionModel>(
            predicate: #Predicate { $0.id == collectionId }
        )
        fetch.fetchLimit = 1

        let existing = try modelContext.fetch(fetch)

        if let existingItem = existing.first {
            updateModel(existingItem, from: dto)
        } else {
            let newItem = MangaCollectionModel(from: dto)
            modelContext.insert(newItem)
        }

        if modelContext.hasChanges {
            try modelContext.save()
        }
    }

    // MARK: - Local CRUD Operations

    /// Fetches all collection items from local storage
    func fetchLocalCollection() throws -> [MangaCollectionModel] {
        let fetch = FetchDescriptor<MangaCollectionModel>(
            sortBy: [SortDescriptor(\.title)]
        )
        return try modelContext.fetch(fetch)
    }

    /// Fetches a single item by manga ID
    func fetchItem(mangaId: Int) throws -> MangaCollectionModel? {
        var fetch = FetchDescriptor<MangaCollectionModel>(
            predicate: #Predicate { $0.mangaId == mangaId }
        )
        fetch.fetchLimit = 1
        return try modelContext.fetch(fetch).first
    }

    /// Deletes an item from local storage by manga ID
    func deleteItem(mangaId: Int) throws {
        let fetch = FetchDescriptor<MangaCollectionModel>(
            predicate: #Predicate { $0.mangaId == mangaId }
        )
        let items = try modelContext.fetch(fetch)

        for item in items {
            modelContext.delete(item)
        }

        if modelContext.hasChanges {
            try modelContext.save()
        }
    }

    /// Deletes all collection items (for cleanup/logout)
    func deleteAllItems() throws {
        let fetch = FetchDescriptor<MangaCollectionModel>()
        let items = try modelContext.fetch(fetch)

        for item in items {
            modelContext.delete(item)
        }

        if modelContext.hasChanges {
            try modelContext.save()
        }
    }

    /// Removes items that are no longer in the API response
    func removeStaleItems(currentIds: Set<String>) throws {
        let fetch = FetchDescriptor<MangaCollectionModel>()
        let allItems = try modelContext.fetch(fetch)

        for item in allItems {
            if !currentIds.contains(item.id) {
                modelContext.delete(item)
            }
        }

        if modelContext.hasChanges {
            try modelContext.save()
        }
    }

    // MARK: - Statistics

    /// Returns collection statistics
    func getStatistics() throws -> CollectionStatistics {
        let fetch = FetchDescriptor<MangaCollectionModel>()
        let items = try modelContext.fetch(fetch)

        return CollectionStatistics(
            totalMangas: items.count,
            completeCollectionCount: items.filter { $0.completeCollection }.count,
            currentlyReadingCount: items.filter { $0.readingVolume != nil }.count,
            totalVolumesOwned: items.reduce(0) { $0 + $1.volumesOwned.count }
        )
    }

    // MARK: - Pending Changes (Offline Queue)

    /// Queues a collection change for later sync to API
    func queuePendingChange(_ request: UserMangaCollectionRequest) throws {
        let mangaId = request.manga

        // Remove any existing pending change for this manga (replace with latest)
        var existingFetch = FetchDescriptor<PendingCollectionChange>(
            predicate: #Predicate { $0.mangaId == mangaId }
        )
        existingFetch.fetchLimit = 1

        if let existing = try modelContext.fetch(existingFetch).first {
            modelContext.delete(existing)
        }

        // Create new pending change
        let pendingChange = PendingCollectionChange(
            mangaId: request.manga,
            volumesOwned: request.volumesOwned,
            readingVolume: request.readingVolume,
            completeCollection: request.completeCollection,
            changeType: .update
        )
        modelContext.insert(pendingChange)

        if modelContext.hasChanges {
            try modelContext.save()
        }
    }

    /// Queues a delete operation for later sync to API
    func queuePendingDelete(mangaId: Int) throws {
        // Remove any existing pending change for this manga
        let existingFetch = FetchDescriptor<PendingCollectionChange>(
            predicate: #Predicate { $0.mangaId == mangaId }
        )

        for existing in try modelContext.fetch(existingFetch) {
            modelContext.delete(existing)
        }

        // Create delete pending change
        let pendingChange = PendingCollectionChange(
            mangaId: mangaId,
            volumesOwned: [],
            readingVolume: nil,
            completeCollection: false,
            changeType: .delete
        )
        modelContext.insert(pendingChange)

        if modelContext.hasChanges {
            try modelContext.save()
        }
    }

    /// Fetches all pending changes ordered by timestamp
    func fetchPendingChanges() throws -> [PendingCollectionChange] {
        let fetch = FetchDescriptor<PendingCollectionChange>(
            sortBy: [SortDescriptor(\.timestamp)]
        )
        return try modelContext.fetch(fetch)
    }

    /// Returns count of pending changes
    func pendingChangesCount() throws -> Int {
        let fetch = FetchDescriptor<PendingCollectionChange>()
        return try modelContext.fetchCount(fetch)
    }

    /// Removes a pending change after successful sync
    func removePendingChange(mangaId: Int) throws {
        let fetch = FetchDescriptor<PendingCollectionChange>(
            predicate: #Predicate { $0.mangaId == mangaId }
        )

        for item in try modelContext.fetch(fetch) {
            modelContext.delete(item)
        }

        if modelContext.hasChanges {
            try modelContext.save()
        }
    }

    /// Clears all pending changes
    func clearAllPendingChanges() throws {
        let fetch = FetchDescriptor<PendingCollectionChange>()

        for item in try modelContext.fetch(fetch) {
            modelContext.delete(item)
        }

        if modelContext.hasChanges {
            try modelContext.save()
        }
    }

    // MARK: - Local Update (for offline changes)

    /// Updates local collection item directly (for offline modifications)
    func updateLocalItem(mangaId: Int, volumesOwned: [Int], readingVolume: Int?, completeCollection: Bool) throws {
        var fetch = FetchDescriptor<MangaCollectionModel>(
            predicate: #Predicate { $0.mangaId == mangaId }
        )
        fetch.fetchLimit = 1

        guard let item = try modelContext.fetch(fetch).first else { return }

        item.volumesOwned = volumesOwned
        item.readingVolume = readingVolume
        item.completeCollection = completeCollection

        if modelContext.hasChanges {
            try modelContext.save()
        }
    }

    // MARK: - Private Helpers

    private func updateModel(_ model: MangaCollectionModel, from dto: UserMangaCollectionDTO) {
        let encoder = JSONEncoder()

        // Update collection data
        model.volumesOwned = dto.volumesOwned
        model.readingVolume = dto.readingVolume
        model.completeCollection = dto.completeCollection

        // Update manga data
        model.mangaId = dto.manga.id
        model.title = dto.manga.title
        model.titleEnglish = dto.manga.titleEnglish
        model.titleJapanese = dto.manga.titleJapanese
        model.status = dto.manga.status.rawValue
        model.volumes = dto.manga.volumes
        model.chapters = dto.manga.chapters
        model.score = dto.manga.score
        model.mainPicture = dto.manga.mainPicture
        model.sypnosis = dto.manga.sypnosis
        model.background = dto.manga.background
        model.url = dto.manga.url
        model.startDate = dto.manga.startDate
        model.endDate = dto.manga.endDate

        // Update relationships
        model.authorsJSON = (try? encoder.encode(dto.manga.authors))
            .flatMap { String(data: $0, encoding: .utf8) }
        model.genresJSON = (try? encoder.encode(dto.manga.genres))
            .flatMap { String(data: $0, encoding: .utf8) }
        model.themesJSON = (try? encoder.encode(dto.manga.themes))
            .flatMap { String(data: $0, encoding: .utf8) }
        model.demographicsJSON = (try? encoder.encode(dto.manga.demographics))
            .flatMap { String(data: $0, encoding: .utf8) }
    }
}

// MARK: - Supporting Types

struct CollectionStatistics: Sendable {
    let totalMangas: Int
    let completeCollectionCount: Int
    let currentlyReadingCount: Int
    let totalVolumesOwned: Int
}
