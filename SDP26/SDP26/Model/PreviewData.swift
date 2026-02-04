//
//  PreviewData.swift
//  SDP26
//
//  Created by José Luis Corral López on 2/2/26.
//

import Foundation

enum PreviewData {
    private static func date(_ string: String) -> Date? {
        ISO8601DateFormatter().date(from: string + "T00:00:00Z")
    }

    static let author = AuthorDTO(
        id: UUID(),
        firstName: "Kentaro",
        lastName: "Miura",
        role: .storyAndArt
    )

    static let author2 = AuthorDTO(
        id: UUID(),
        firstName: "Eiichiro",
        lastName: "Oda",
        role: .storyAndArt
    )

    static let genre = GenreDTO(id: UUID(), genre: "Action")
    static let genre2 = GenreDTO(id: UUID(), genre: "Adventure")
    static let genre3 = GenreDTO(id: UUID(), genre: "Fantasy")

    static let theme = ThemeDTO(id: UUID(), theme: "Dark Fantasy")
    static let theme2 = ThemeDTO(id: UUID(), theme: "Military")

    static let demographic = DemographicDTO(id: UUID(), demographic: .seinen)

    static let manga = MangaDTO(
        id: 1,
        title: "Berserk",
        titleEnglish: "Berserk",
        titleJapanese: "ベルセルク",
        status: .ongoing,
        startDate: date("1989-08-25"),
        endDate: nil,
        chapters: 364,
        volumes: 41,
        score: 9.43,
        mainPicture: "https://cdn.myanimelist.net/images/manga/1/157897l.jpg",
        sypnosis: "Guts, a former mercenary now known as the Black Swordsman, is out for revenge. After a tumultuous childhood, he finally finds someone he respects and believes he can trust, only to have everything fall apart when this person takes away everything important to Guts for the purpose of fulfilling his own desires.",
        background: "Berserk won the Award for Excellence at the sixth installment of Tezuka Osamu Cultural Prize in 2002.",
        url: "https://myanimelist.net/manga/2/Berserk",
        authors: [author],
        genres: [genre, genre2, genre3],
        themes: [theme, theme2],
        demographics: [demographic]
    )

    static let mangaSimple = MangaDTO(
        id: 2,
        title: "One Piece",
        titleEnglish: "One Piece",
        titleJapanese: "ワンピース",
        status: .ongoing,
        startDate: date("1997-07-22"),
        endDate: nil,
        chapters: nil,
        volumes: 107,
        score: 9.21,
        mainPicture: nil,
        sypnosis: "Gol D. Roger was known as the Pirate King, the strongest and most infamous being to have sailed the Grand Line.",
        background: nil,
        url: nil,
        authors: [author2],
        genres: [genre, genre2],
        themes: [],
        demographics: []
    )

    static let mangas = [manga, mangaSimple]
    static let authors = [author, author2]
    static let genres = ["Action", "Adventure", "Comedy", "Drama", "Fantasy", "Horror", "Romance", "Sci-Fi"]
    static let themes = ["Dark Fantasy", "Military", "School", "Super Power", "Supernatural"]
    static let demographics = ["Shounen", "Seinen", "Shoujo", "Josei"]
}
