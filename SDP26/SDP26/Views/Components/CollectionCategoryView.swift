//
//  CollectionCategoryView.swift
//  SDP26
//
//  Created by José Luis Corral López on 4/2/26.
//

import SwiftUI

struct CollectionCategoryView: View {
    let title: String
    let icon: String
    let items: [UserMangaCollectionDTO]

    @State private var selectedManga: MangaDTO?

    private let columns = [GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 16)]

    var body: some View {
        ScrollView {
            if items.isEmpty {
                ContentUnavailableView("No mangas", systemImage: icon)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(items) { item in
                        Button { selectedManga = item.manga } label: {
                            MangaCard(manga: item.manga)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedManga) { manga in
            MangaDetailView(manga: manga)
        }
    }
}

#Preview("Collection Category") {
    NavigationStack {
        CollectionCategoryView(title: "Complete", icon: "checkmark.circle.fill", items: [])
    }
}
