//
//  CollectionView.swift
//  SDP26
//
//  Created by José Luis Corral López on 4/2/26.
//

import SwiftUI

struct CollectionView: View {
    @Bindable var vm = BestMangaViewModel.shared
    @State private var selectedManga: MangaDTO?

    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                if vm.isLoading && vm.mangas.isEmpty {
                    ProgressView("Loading collection...")
                        .frame(maxWidth: .infinity, minHeight: 300)
                } else if vm.mangas.isEmpty {
                    emptyState
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(vm.mangas) { manga in
                            Button {
                                selectedManga = manga
                            } label: {
                                MangaCard(manga: manga)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    // TODO: Implement delete
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("My Collection")
            .navigationDestination(item: $selectedManga) { manga in
                MangaDetailView(manga: manga)
            }
            .task {
                if vm.mangas.isEmpty {
                    await vm.loadNextPage()
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No mangas",
            systemImage: "books.vertical",
            description: Text("Your collection is empty. Add mangas from the Mangas tab.")
        )
        .frame(maxWidth: .infinity, minHeight: 300)
    }
}

#Preview {
    CollectionView()
}
