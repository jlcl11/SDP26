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
    
    static let getDemographics = api.appending(path: "list/demographics")
    static let getGenres = api.appending(path: "list/genres")
    static let getThemes = api.appending(path: "list/themes")
}
