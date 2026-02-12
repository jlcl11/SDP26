//
//  MangaCollectionEditor.swift
//  SDP26
//
//  Manages collection editing state for manga detail views.
//

import Foundation

@Observable @MainActor
final class MangaCollectionEditor {
    private let manga: MangaDTO
    private let collectionVM: CollectionVM

    var volumesOwned: Set<Int> = []
    var readingVolume: Int?
    private var saveTask: Task<Void, Never>?

    init(manga: MangaDTO, collectionVM: CollectionVM = .shared) {
        self.manga = manga
        self.collectionVM = collectionVM
    }

    func load() async {
        if collectionVM.collection.isEmpty {
            await collectionVM.loadCollection()
        }

        if let item = collectionVM.getItem(for: manga.id) {
            volumesOwned = Set(item.volumesOwned)
            readingVolume = item.readingVolume
        }
    }

    func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await save()
        }
    }

    func save() async {
        let request = UserMangaCollectionRequest(
            volumesOwned: volumesOwned.sorted(),
            completeCollection: volumesOwned.count >= (manga.volumes ?? 0),
            manga: manga.id,
            readingVolume: readingVolume
        )
        await collectionVM.addOrUpdateManga(request)
    }
}
