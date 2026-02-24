//
//  iPadContentView.swift
//  SDP26
//
//  Created by José Luis Corral López on 10/2/26.
//

import SwiftUI

enum iPadNavigationItem: String, CaseIterable, Identifiable {
    case mangas = "Mangas"
    case authors = "Authors"
    case collection = "Collection"
    case profile = "Profile"
    case search = "Search"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .mangas: "book.fill"
        case .authors: "person.2"
        case .collection: "books.vertical"
        case .profile: "person.circle"
        case .search: "magnifyingglass"
        }
    }
}

struct iPadContentView: View {
    @State private var selectedItem: iPadNavigationItem? = .mangas
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(iPadNavigationItem.allCases, selection: $selectedItem) { item in
                Label(item.rawValue, systemImage: item.icon)
                    .tag(item)
            }
            .navigationTitle("MangaVault")
            .listStyle(.sidebar)
        } detail: {
            NavigationStack {
                switch selectedItem {
                case .mangas:
                    iPadMangaListView()
                case .authors:
                    iPadAuthorsListView()
                case .collection:
                    iPadCollectionView()
                case .profile:
                    ProfileView()
                case .search:
                    iPadSearchView()
                case .none:
                    ContentUnavailableView(
                        "Select a section",
                        systemImage: "sidebar.left",
                        description: Text("Choose a section from the sidebar")
                    )
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    iPadContentView()
}
