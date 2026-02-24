//
//  CollectionView.swift
//  SDP26
//
//  Created by José Luis Corral López on 5/2/26.
//

import SwiftUI
import SwiftData

struct CollectionView: View {
    @Environment(\.modelContext) private var modelContext
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
                    // Status banners
                    if collectionVM.isSyncing {
                        StatusBanner.syncing()
                    } else if collectionVM.pendingChangesCount > 0 {
                        StatusBanner.pendingChanges(count: collectionVM.pendingChangesCount)
                    } else if collectionVM.isOffline {
                        StatusBanner.offline()
                    }

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
                // Configure VM with ModelContainer for local persistence
                collectionVM.configure(with: modelContext.container)

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

    private var progress: Double {
        guard let total = item.manga.volumes, total > 0 else { return 0 }
        return Double(item.volumesOwned.count) / Double(total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Image with overlays
            CachedAsyncImage(url: item.manga.imageURL, width: 100, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(alignment: .bottom) {
                    // Gradient + Progress overlay
                    VStack(spacing: 4) {
                        Spacer()

                        // Reading indicator
                        if let readingVolume = item.readingVolume {
                            Text("Vol. \(readingVolume)")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                        }

                        // Progress bar
                        if let totalVolumes = item.manga.volumes, totalVolumes > 0 {
                            VStack(spacing: 2) {
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(.white.opacity(0.3))
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(item.completeCollection ? .green : .white)
                                            .frame(width: geo.size.width * progress)
                                    }
                                }
                                .frame(height: 4)

                                Text("\(item.volumesOwned.count)/\(totalVolumes)")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .padding(6)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .overlay(alignment: .topTrailing) {
                    // Complete badge
                    if item.completeCollection {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                            .background(Circle().fill(.white).padding(-2))
                            .padding(4)
                    }
                }

            // Title
            Text(item.manga.title)
                .cardTitle()

            // Score
            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                Text(item.manga.score.formatted(.number.precision(.fractionLength(2))))
            }
            .secondaryText()
        }
        .frame(width: 100)
    }
}

#Preview {
    CollectionView()
}
