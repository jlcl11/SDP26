//
//  MangaCollectionModel.swift
//  SDP26
//
//  SwiftData model for persisting user's manga collection locally.
//  Enables offline access to the user's collection.
//

import Foundation
import SwiftData

@Model
final class MangaCollectionModel {
    // MARK: - Indexes for Performance
    #Index<MangaCollectionModel>([\.mangaId], [\.title])

    // MARK: - Unique Identifier
    /// The collection entry ID from the API
    @Attribute(.unique) var id: String

    // MARK: - Collection Data (User's Progress)
    /// Array of volume numbers the user owns
    var volumesOwned: [Int]

    /// The volume the user is currently reading (nil if not reading)
    var readingVolume: Int?

    /// Whether the user has completed the collection
    var completeCollection: Bool

    // MARK: - Manga Data (For Offline Display)
    /// The manga's unique ID from the API
    var mangaId: Int

    /// Manga title
    var title: String

    /// English title (optional)
    var titleEnglish: String?

    /// Japanese title (optional)
    var titleJapanese: String?

    /// Publication status
    var status: String

    /// Total number of volumes (nil if unknown/ongoing)
    var volumes: Int?

    /// Total number of chapters (nil if unknown)
    var chapters: Int?

    /// User score/rating
    var score: Double

    /// URL to the manga cover image
    var mainPicture: String?

    /// Synopsis text
    var sypnosis: String?

    /// Background information
    var background: String?

    /// External URL
    var url: String?

    /// Start publication date
    var startDate: Date?

    /// End publication date
    var endDate: Date?

    // MARK: - Relationships stored as JSON strings for simplicity
    /// Authors as JSON array string
    var authorsJSON: String?

    /// Genres as JSON array string
    var genresJSON: String?

    /// Themes as JSON array string
    var themesJSON: String?

    /// Demographics as JSON array string
    var demographicsJSON: String?

    // MARK: - Initialization

    init(
        id: String,
        volumesOwned: [Int],
        readingVolume: Int?,
        completeCollection: Bool,
        mangaId: Int,
        title: String,
        titleEnglish: String? = nil,
        titleJapanese: String? = nil,
        status: String,
        volumes: Int? = nil,
        chapters: Int? = nil,
        score: Double,
        mainPicture: String? = nil,
        sypnosis: String? = nil,
        background: String? = nil,
        url: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        authorsJSON: String? = nil,
        genresJSON: String? = nil,
        themesJSON: String? = nil,
        demographicsJSON: String? = nil
    ) {
        self.id = id
        self.volumesOwned = volumesOwned
        self.readingVolume = readingVolume
        self.completeCollection = completeCollection
        self.mangaId = mangaId
        self.title = title
        self.titleEnglish = titleEnglish
        self.titleJapanese = titleJapanese
        self.status = status
        self.volumes = volumes
        self.chapters = chapters
        self.score = score
        self.mainPicture = mainPicture
        self.sypnosis = sypnosis
        self.background = background
        self.url = url
        self.startDate = startDate
        self.endDate = endDate
        self.authorsJSON = authorsJSON
        self.genresJSON = genresJSON
        self.themesJSON = themesJSON
        self.demographicsJSON = demographicsJSON
    }
}

// MARK: - Computed Properties

extension MangaCollectionModel {
    /// URL for the manga cover image
    var imageURL: URL? {
        guard let picture = mainPicture else { return nil }
        return URL(string: picture.trimmingCharacters(in: CharacterSet(charactersIn: "\"")))
    }

    /// Progress percentage (0.0 to 1.0)
    var progress: Double {
        guard let totalVolumes = volumes, totalVolumes > 0 else { return 0 }
        return Double(volumesOwned.count) / Double(totalVolumes)
    }

    /// Decoded authors array
    var authors: [AuthorDTO] {
        guard let json = authorsJSON,
              let data = json.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([AuthorDTO].self, from: data)) ?? []
    }

    /// Decoded genres array
    var genres: [GenreDTO] {
        guard let json = genresJSON,
              let data = json.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([GenreDTO].self, from: data)) ?? []
    }

    /// Decoded themes array
    var themes: [ThemeDTO] {
        guard let json = themesJSON,
              let data = json.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([ThemeDTO].self, from: data)) ?? []
    }

    /// Decoded demographics array
    var demographics: [DemographicDTO] {
        guard let json = demographicsJSON,
              let data = json.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([DemographicDTO].self, from: data)) ?? []
    }

    /// Manga status as enum
    var mangaStatus: MangaStatus {
        MangaStatus(rawValue: status) ?? .none
    }
}

// MARK: - Conversion from DTO

extension MangaCollectionModel {
    /// Creates a MangaCollectionModel from a UserMangaCollectionDTO
    convenience init(from dto: UserMangaCollectionDTO) {
        let encoder = JSONEncoder()

        let authorsJSON = (try? encoder.encode(dto.manga.authors))
            .flatMap { String(data: $0, encoding: .utf8) }

        let genresJSON = (try? encoder.encode(dto.manga.genres))
            .flatMap { String(data: $0, encoding: .utf8) }

        let themesJSON = (try? encoder.encode(dto.manga.themes))
            .flatMap { String(data: $0, encoding: .utf8) }

        let demographicsJSON = (try? encoder.encode(dto.manga.demographics))
            .flatMap { String(data: $0, encoding: .utf8) }

        self.init(
            id: dto.id,
            volumesOwned: dto.volumesOwned,
            readingVolume: dto.readingVolume,
            completeCollection: dto.completeCollection,
            mangaId: dto.manga.id,
            title: dto.manga.title,
            titleEnglish: dto.manga.titleEnglish,
            titleJapanese: dto.manga.titleJapanese,
            status: dto.manga.status.rawValue,
            volumes: dto.manga.volumes,
            chapters: dto.manga.chapters,
            score: dto.manga.score,
            mainPicture: dto.manga.mainPicture,
            sypnosis: dto.manga.sypnosis,
            background: dto.manga.background,
            url: dto.manga.url,
            startDate: dto.manga.startDate,
            endDate: dto.manga.endDate,
            authorsJSON: authorsJSON,
            genresJSON: genresJSON,
            themesJSON: themesJSON,
            demographicsJSON: demographicsJSON
        )
    }

    /// Converts the model back to a DTO for API operations
    func toDTO() -> UserMangaCollectionDTO {
        let mangaDTO = MangaDTO(
            id: mangaId,
            title: title,
            titleEnglish: titleEnglish,
            titleJapanese: titleJapanese,
            status: mangaStatus,
            startDate: startDate,
            endDate: endDate,
            chapters: chapters,
            volumes: volumes,
            score: score,
            mainPicture: mainPicture,
            sypnosis: sypnosis,
            background: background,
            url: url,
            authors: authors,
            genres: genres,
            themes: themes,
            demographics: demographics
        )

        return UserMangaCollectionDTO(
            completeCollection: completeCollection,
            id: id,
            volumesOwned: volumesOwned,
            manga: mangaDTO,
            readingVolume: readingVolume
        )
    }
}
