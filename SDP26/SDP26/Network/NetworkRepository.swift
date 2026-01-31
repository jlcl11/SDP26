//
//  NetworkRepository.swift
//  SDP26
//
//  Created by José Luis Corral López on 29/1/26.
//

import Foundation
import NetworkAPI

protocol MangaRepository: Sendable {
    func getMangas(page: Int) async throws -> MangaPageDTO
}

protocol AuthorRepository: Sendable {
    func getAuthors(page: Int) async throws -> AuthorPageDTO
}

struct NetworkRepository: NetworkInteractor, MangaRepository, AuthorRepository, Sendable {
    func getAuthors(page: Int) async throws -> AuthorPageDTO {
        try await getJSON(.get(url: .getAuthors(page: page)), type: AuthorPageDTO.self)
    }

    func getMangas(page: Int) async throws -> MangaPageDTO {
        try await getJSON(.get(url: .getMangas(page: page)), type: MangaPageDTO.self)
    }
}
