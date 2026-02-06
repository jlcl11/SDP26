//
//  MangasByAuthorViewModel.swift
//  SDP26
//
//  Created by José Luis Corral López on 6/2/26.
//

import Foundation

@Observable
final class MangasByAuthorViewModel {
    private(set) var mangas: [MangaDTO] = []
    private(set) var isLoading = false
    private(set) var author: AuthorDTO?
    private var currentAuthorID: UUID?
    private let dataSource: MangasByAuthorDataSource

    init(dataSource: MangasByAuthorDataSource = MangasByAuthorDataSource(repository: NetworkRepository())) {
        self.dataSource = dataSource
    }

    func fetchMangasByAuthor(author: AuthorDTO) async {
        guard !isLoading else { return }

        if author.id != currentAuthorID {
            mangas = []
            self.author = author
            currentAuthorID = author.id
            await dataSource.reset()
        }

        isLoading = true

        do {
            let newMangas = try await dataSource.fetchNextPage(authorID: author.id)
            mangas.append(contentsOf: newMangas)
        } catch {
            print("Error: \(error)")
        }

        isLoading = false
    }

    func loadNextPage() async {
        guard let author = author else { return }
        await fetchMangasByAuthor(author: author)
    }

    func reset() async {
        mangas = []
        author = nil
        currentAuthorID = nil
        await dataSource.reset()
    }

    func findAuthorRole(in manga: MangaDTO) -> AuthorRole {
        guard let author = author else { return .none }
        if let mangaAuthor = manga.authors.first(where: { $0.id == author.id }) {
            return mangaAuthor.role
        }
        return author.role
    }
}
