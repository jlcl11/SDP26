//
//  CollectionView.swift
//  SDP26
//
//  Created by José Luis Corral López on 4/2/26.
//

import SwiftUI

struct CollectionView: View {
    @State private var collectionVM = CollectionVM.shared
    @State private var selectedManga: MangaDTO?

    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                if collectionVM.isLoading && collectionVM.collection.isEmpty {
                    ProgressView("Loading collection...")
                        .frame(maxWidth: .infinity, minHeight: 300)
                } else if collectionVM.collection.isEmpty {
                    emptyState
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(collectionVM.collection) { item in
                            Button {
                                selectedManga = item.manga
                            } label: {
                                CollectionMangaCard(item: item)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    Task {
                                        await collectionVM.deleteManga(id: item.manga.id)
                                    }
                                } label: {
                                    Label("Remove from collection", systemImage: "trash")
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
                if collectionVM.collection.isEmpty {
                    await collectionVM.loadCollection()
                }
            }
            .refreshable {
                await collectionVM.loadCollection()
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

// MARK: - Collection Manga Card

private struct CollectionMangaCard: View {
    let item: UserMangaCollectionDTO

    var body: some View {
        VStack(spacing: 8) {
            MangaCard(manga: item.manga)

            // Progress indicator
            if let totalVolumes = item.manga.volumes, totalVolumes > 0 {
                ProgressView(value: Double(item.volumesOwned.count), total: Double(totalVolumes))
                    .tint(item.completeCollection ? .green : .blue)

                Text("\(item.volumesOwned.count)/\(totalVolumes)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            // Reading indicator
            if let readingVolume = item.readingVolume {
                Text("Reading Vol. \(readingVolume)")
                    .font(.caption2)
                    .foregroundStyle(.blue)
            }
        }
    }
}

#Preview {
    CollectionView()
}
