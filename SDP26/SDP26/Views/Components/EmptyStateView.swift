//
//  EmptyStateView.swift
//  SDP26
//
//  Created by José Luis Corral López on 19/1/26.
//

import SwiftUI

struct EmptyStateView: View {
    let title: String
    let systemImage: String
    let description: String

    var body: some View {
        ContentUnavailableView(title,
                               systemImage: systemImage,
                               description: Text(description))
    }
}

extension EmptyStateView {
    static func noSearchResults(for searchText: String, type: ContentType) -> EmptyStateView {
        EmptyStateView(
            title: "No \(type.plural) found",
            systemImage: type.systemImage,
            description: "No \(type.plural) match \"\(searchText)\""
        )
    }

    static func noFilterResults() -> EmptyStateView {
        EmptyStateView(
            title: "No results found",
            systemImage: "magnifyingglass",
            description: "Try adjusting your search filters"
        )
    }

    static func noContent(type: ContentType) -> EmptyStateView {
        EmptyStateView(
            title: "No \(type.plural) available",
            systemImage: type.systemImage,
            description: "Check your connection and try again"
        )
    }
}

enum ContentType {
    case manga
    case author

    var plural: String {
        switch self {
        case .manga: "mangas"
        case .author: "authors"
        }
    }

    var systemImage: String {
        switch self {
        case .manga: "book"
        case .author: "person"
        }
    }
}

#Preview("No Search Results") {
    EmptyStateView.noSearchResults(for: "Naruto", type: .manga)
}

#Preview("No Filter Results") {
    EmptyStateView.noFilterResults()
}

#Preview("No Content") {
    EmptyStateView.noContent(type: .author)
}
