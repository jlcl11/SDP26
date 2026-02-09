//
//  MangaCollectionTool.swift
//  SDP26
//
//  Created by José Luis Corral López on 9/2/26.
//

import Foundation
import FoundationModels

/// Tool that provides the Foundation Model access to the user's manga collection data
final class MangaCollectionTool: Tool {
    typealias Output = String

    nonisolated let name = "getMangaCollection"
    nonisolated let description = "Retrieves the user's manga collection with details about genres, themes, demographics, reading progress, and completion status."

    @Generable
    struct Arguments: Sendable {
        @Guide(description: "Whether to include detailed statistics about the collection")
        let includeStats: Bool
    }

    nonisolated func call(arguments: Arguments) async throws -> String {
        // Fetch data from MainActor-isolated CollectionVM
        let collectionData = await MainActor.run {
            let vm = CollectionVM.shared
            return CollectionSnapshot(
                collection: vm.collection,
                totalVolumesOwned: vm.totalVolumesOwned,
                completeCollectionCount: vm.completeCollectionCount,
                currentlyReadingCount: vm.currentlyReadingCount
            )
        }

        return buildSummary(from: collectionData)
    }

    private nonisolated func buildSummary(from data: CollectionSnapshot) -> String {
        var summary = "User's Manga Collection Analysis:\n\n"

        // Basic stats
        summary += "Total mangas: \(data.collection.count)\n"
        summary += "Total volumes owned: \(data.totalVolumesOwned)\n"
        summary += "Complete collections: \(data.completeCollectionCount)\n"
        summary += "Currently reading: \(data.currentlyReadingCount)\n\n"

        // Collect genres, themes, and demographics
        var genreCounts: [String: Int] = [:]
        var themeCounts: [String: Int] = [:]
        var demographicCounts: [String: Int] = [:]
        var statusCounts: [String: Int] = [:]
        var totalScore: Double = 0
        var scoreCount = 0

        for item in data.collection {
            let manga = item.manga

            for genre in manga.genres {
                genreCounts[genre.genre, default: 0] += 1
            }

            for theme in manga.themes {
                themeCounts[theme.theme, default: 0] += 1
            }

            for demo in manga.demographics {
                demographicCounts[demo.demographic.rawValue, default: 0] += 1
            }

            statusCounts[manga.status.rawValue, default: 0] += 1
            totalScore += manga.score
            scoreCount += 1
        }

        // Top genres
        let topGenres = genreCounts.sorted { $0.value > $1.value }.prefix(5)
        summary += "Top genres:\n"
        for (genre, count) in topGenres {
            summary += "  - \(genre): \(count) mangas\n"
        }

        // Top themes
        let topThemes = themeCounts.sorted { $0.value > $1.value }.prefix(5)
        summary += "\nTop themes:\n"
        for (theme, count) in topThemes {
            summary += "  - \(theme): \(count) mangas\n"
        }

        // Demographics
        summary += "\nDemographics:\n"
        for (demo, count) in demographicCounts.sorted(by: { $0.value > $1.value }) {
            summary += "  - \(demo): \(count) mangas\n"
        }

        // Average score
        if scoreCount > 0 {
            let avgScore = totalScore / Double(scoreCount)
            summary += "\nAverage score of collection: \(String(format: "%.2f", avgScore))\n"
        }

        // Reading patterns
        let readingMangas = data.collection.filter { $0.readingVolume != nil }
        if !readingMangas.isEmpty {
            summary += "\nCurrently reading:\n"
            for item in readingMangas.prefix(5) {
                let progress = item.manga.volumes.map { "Vol. \(item.readingVolume ?? 0)/\($0)" } ?? "Vol. \(item.readingVolume ?? 0)"
                summary += "  - \(item.manga.title) (\(progress))\n"
            }
        }

        // Completion rate
        let completedCount = data.collection.filter { $0.completeCollection }.count
        if data.collection.count > 0 {
            let completionRate = Double(completedCount) / Double(data.collection.count) * 100
            summary += "\nCollection completion rate: \(String(format: "%.1f", completionRate))%\n"
        }

        // List some manga titles for context
        summary += "\nSample titles in collection:\n"
        for item in data.collection.prefix(10) {
            let status = item.completeCollection ? "(Complete)" : "(In progress)"
            summary += "  - \(item.manga.title) \(status)\n"
        }

        return summary
    }
}

// MARK: - Snapshot for crossing actor boundaries

private struct CollectionSnapshot: Sendable {
    let collection: [UserMangaCollectionDTO]
    let totalVolumesOwned: Int
    let completeCollectionCount: Int
    let currentlyReadingCount: Int
}
