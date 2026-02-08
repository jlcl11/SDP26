//
//  URL.swift
//  SDP26
//
//  Created by José Luis Corral López on 29/1/26.
//

import Foundation

let api = URL(string: "https://mymanga-acacademy-5607149ebe3d.herokuapp.com")!

extension URL {
    static func getMangas(page: Int, per: Int = 20) -> URL {
        api.appending(path: "list/mangas")
           .appending(queryItems: [
               URLQueryItem(name: "page", value: String(page)),
               URLQueryItem(name: "per", value: String(per))
           ])
    }

    static func getAuthors(page: Int, per: Int = 20) -> URL {
        api.appending(path: "list/authorsPaged")
           .appending(queryItems: [
               URLQueryItem(name: "page", value: String(page)),
               URLQueryItem(name: "per", value: String(per))
           ])
    }
    
    static func getBestMangas(page: Int, per: Int = 20) -> URL {
        api.appending(path: "list/bestMangas")
           .appending(queryItems: [
               URLQueryItem(name: "page", value: String(page)),
               URLQueryItem(name: "per", value: String(per))
           ])
    }
    
    static func getMangasByAuthor(page: Int, per: Int = 20, authorID:UUID) -> URL {
        api.appending(path: "list/mangaByAuthor/\(authorID)")
           .appending(queryItems: [
               URLQueryItem(name: "page", value: String(page)),
               URLQueryItem(name: "per", value: String(per))
           ])
    }
    
    static func getMangaBeginsWith(name: String) -> URL {
        api.appending(path: "search/mangasBeginsWith/\(name)")
    }
    
    static func getAuthorByName(name: String) -> URL {
        api.appending(path: "search/author/\(name)")
    }

    static func customSearch(page: Int, per: Int = 20) -> URL {
        api.appending(path: "search/manga")
           .appending(queryItems: [
               URLQueryItem(name: "page", value: String(page)),
               URLQueryItem(name: "per", value: String(per))
           ])
    }

    static let getDemographics = api.appending(path: "list/demographics")
    static let getGenres = api.appending(path: "list/genres")
    static let getThemes = api.appending(path: "list/themes")

    // MARK: - Auth Endpoints
    static let createUser = api.appending(path: "users")
    static let loginJWT = api.appending(path: "users/jwt/login")
    static let refreshJWT = api.appending(path: "users/jwt/refresh")
    static let meJWT = api.appending(path: "users/jwt/me")

    // MARK: - Collection Endpoints
    static let collection = api.appending(path: "collection/manga")

    static func collectionManga(id: Int) -> URL {
        api.appending(path: "collection/manga/\(id)")
    }
}
