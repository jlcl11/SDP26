//
//  PreviewContainer.swift
//  SDP26
//
//  SwiftUI Preview support for SwiftData.
//  Provides in-memory container with sample collection data.
//

import SwiftUI
import SwiftData

struct PreviewContainer: PreviewModifier {
    static func makeSharedContext() async throws -> ModelContainer {
        // Create in-memory configuration for previews
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: [MangaCollectionModel.self, PendingCollectionChange.self],
            configurations: configuration
        )

        // Insert sample collection data
        for item in MangaCollectionModel.sampleCollection {
            container.mainContext.insert(item)
        }

        try container.mainContext.save()
        return container
    }

    func body(content: Content, context: ModelContainer) -> some View {
        content
            .modelContainer(context)
    }
}

// MARK: - Preview Trait Extension

extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var sampleCollectionData: Self = .modifier(PreviewContainer())
}

// MARK: - Sample Collection Data

extension MangaCollectionModel {
    @MainActor static let sampleBerserk = MangaCollectionModel(
        id: "collection-1",
        volumesOwned: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
        readingVolume: 8,
        completeCollection: false,
        mangaId: 1,
        title: "Berserk",
        titleEnglish: "Berserk",
        titleJapanese: "ベルセルク",
        status: "ongoing",
        volumes: 41,
        chapters: 364,
        score: 9.43,
        mainPicture: "https://cdn.myanimelist.net/images/manga/1/157897l.jpg",
        sypnosis: "Guts, a former mercenary now known as the Black Swordsman, is out for revenge.",
        background: "Berserk won the Award for Excellence at the sixth installment of Tezuka Osamu Cultural Prize in 2002.",
        url: "https://myanimelist.net/manga/2/Berserk"
    )

    @MainActor static let sampleOnePiece = MangaCollectionModel(
        id: "collection-2",
        volumesOwned: Array(1...107),
        readingVolume: 105,
        completeCollection: true,
        mangaId: 2,
        title: "One Piece",
        titleEnglish: "One Piece",
        titleJapanese: "ワンピース",
        status: "ongoing",
        volumes: 107,
        chapters: nil,
        score: 9.21,
        mainPicture: "https://cdn.myanimelist.net/images/manga/2/253146l.jpg",
        sypnosis: "Gol D. Roger was known as the Pirate King, the strongest and most infamous being to have sailed the Grand Line."
    )

    @MainActor static let sampleNaruto = MangaCollectionModel(
        id: "collection-3",
        volumesOwned: [1, 2, 3, 4, 5],
        readingVolume: nil,
        completeCollection: false,
        mangaId: 3,
        title: "Naruto",
        titleEnglish: "Naruto",
        titleJapanese: "ナルト",
        status: "completed",
        volumes: 72,
        chapters: 700,
        score: 8.07,
        mainPicture: "https://cdn.myanimelist.net/images/manga/3/249658l.jpg",
        sypnosis: "Whenever Naruto Uzumaki proclaims that he will someday become the Hokage—a title bestowed upon the best ninja in the Village Hidden in the Leaves—no one takes him seriously."
    )

    @MainActor static let sampleDragonBall = MangaCollectionModel(
        id: "collection-4",
        volumesOwned: Array(1...42),
        readingVolume: nil,
        completeCollection: true,
        mangaId: 4,
        title: "Dragon Ball",
        titleEnglish: "Dragon Ball",
        titleJapanese: "ドラゴンボール",
        status: "completed",
        volumes: 42,
        chapters: 520,
        score: 8.42,
        mainPicture: "https://cdn.myanimelist.net/images/manga/1/267793l.jpg",
        sypnosis: "Gokuu Son is a young boy who lives in the woods all alone—that is, until a girl named Bulma runs into him in her search for a set of magical objects called the Dragon Balls."
    )

    @MainActor static let sampleCollection: [MangaCollectionModel] = [
        sampleBerserk,
        sampleOnePiece,
        sampleNaruto,
        sampleDragonBall
    ]
}

// MARK: - Collection Preview Data (DTO format for non-SwiftData views)

extension PreviewData {
    static let collectionItem = UserMangaCollectionDTO(
        completeCollection: false,
        id: "preview-1",
        volumesOwned: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
        manga: manga,
        readingVolume: 8
    )

    static let collectionItemComplete = UserMangaCollectionDTO(
        completeCollection: true,
        id: "preview-2",
        volumesOwned: Array(1...41),
        manga: manga,
        readingVolume: nil
    )

    static let collectionItems = [collectionItem, collectionItemComplete]
}
