//
//  PendingCollectionChange.swift
//  SDP26
//
//  SwiftData model for queuing offline collection changes.
//  Changes are synced to API when connectivity is restored.
//

import Foundation
import SwiftData

@Model
final class PendingCollectionChange {
    // MARK: - Unique Identifier
    @Attribute(.unique) var mangaId: Int

    // MARK: - Collection Data
    var volumesOwned: [Int]
    var readingVolume: Int?
    var completeCollection: Bool

    // MARK: - Metadata
    var timestamp: Date
    var changeType: String  // "update" or "delete"

    init(
        mangaId: Int,
        volumesOwned: [Int],
        readingVolume: Int?,
        completeCollection: Bool,
        changeType: ChangeType = .update
    ) {
        self.mangaId = mangaId
        self.volumesOwned = volumesOwned
        self.readingVolume = readingVolume
        self.completeCollection = completeCollection
        self.timestamp = Date()
        self.changeType = changeType.rawValue
    }
}

// MARK: - Change Type

extension PendingCollectionChange {
    enum ChangeType: String {
        case update = "update"
        case delete = "delete"
    }

    var type: ChangeType {
        ChangeType(rawValue: changeType) ?? .update
    }
}

// MARK: - Conversion to API Request

extension PendingCollectionChange {
    func toRequest() -> UserMangaCollectionRequest {
        UserMangaCollectionRequest(
            volumesOwned: volumesOwned,
            completeCollection: completeCollection,
            manga: mangaId,
            readingVolume: readingVolume
        )
    }

    /// Converts to Sendable DTO for crossing actor boundaries
    func toDTO() -> PendingChangeDTO {
        PendingChangeDTO(
            mangaId: mangaId,
            volumesOwned: volumesOwned,
            readingVolume: readingVolume,
            completeCollection: completeCollection,
            timestamp: timestamp,
            changeType: changeType
        )
    }
}
