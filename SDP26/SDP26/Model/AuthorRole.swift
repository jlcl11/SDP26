//
//  AuthorRole.swift
//  SDP26
//
//  Created by José Luis Corral López on 28/1/26.
//

import Foundation

enum AuthorRole: String, CaseIterable, Sendable, Codable {
    case storyAndArt = "Story & Art"
    case story = "Story"
    case art = "Art"
    case none = ""
    
    var icon: String {
        switch self {
        case .storyAndArt: "pencil.and.outline"
        case .story: "text.book.closed"
        case .art: "paintbrush"
        case .none: "person"
        }
    }
    
}
