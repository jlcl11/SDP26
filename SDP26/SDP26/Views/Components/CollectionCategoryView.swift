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
    @Bindable var vm = BestMangaViewModel.shared
    @State private var selectedManga: MangaDTO?

    private let columns = [GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 16)]

    var body: some View {
        ScrollView {
            if vm.mangas.isEmpty {
                ContentUnavailableView("No mangas", systemImage: icon)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(vm.mangas) { manga in
                        Button { selectedManga = manga } label: {
                            MangaCard(manga: manga)
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
        CollectionCategoryView(title: "Complete", icon: "checkmark.circle.fill")
    }
}
