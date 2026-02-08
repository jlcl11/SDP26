//
//  iPadCollectionView.swift
//  SDP26
//
//  Created by José Luis Corral López on 6/2/26.
//

import SwiftUI

struct iPadCollectionView: View {
    @State private var collectionVM = CollectionVM.shared
    @State private var selectedManga: MangaDTO?
    @State private var viewMode: ViewMode = .grid

    enum ViewMode: String, CaseIterable {
        case grid = "Grid"
        case list = "List"

        var icon: String {
            switch self {
            case .grid: "square.grid.2x2"
            case .list: "list.bullet"
            }
        }
    }

    private let columns = [
        GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 20)
    ]

    var body: some View {
        Group {
            if collectionVM.isLoading && collectionVM.collection.isEmpty {
                ProgressView("Loading collection...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if collectionVM.collection.isEmpty {
                ContentUnavailableView(
                    "No mangas",
                    systemImage: "books.vertical",
                    description: Text("Your collection is empty. Add mangas from the Mangas tab.")
                )
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Stats Header
                        HStack(spacing: 24) {
                            CollectionStatCard(
                                title: "Total Mangas",
                                value: "\(collectionVM.totalMangas)",
                                icon: "book.fill",
                                color: .blue
                            )
                            CollectionStatCard(
                                title: "Volumes",
                                value: "\(collectionVM.totalVolumesOwned)",
                                icon: "books.vertical.fill",
                                color: .purple
                            )
                            CollectionStatCard(
                                title: "Reading",
                                value: "\(collectionVM.currentlyReadingCount)",
                                icon: "bookmark.fill",
                                color: .orange
                            )
                            CollectionStatCard(
                                title: "Complete",
                                value: "\(collectionVM.completeCollectionCount)",
                                icon: "checkmark.circle.fill",
                                color: .green
                            )
                        }
                        .padding(.horizontal)

                        Divider()
                            .padding(.horizontal)

                        // Collection Grid/List
                        if viewMode == .grid {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(collectionVM.collection) { item in
                                    Button {
                                        selectedManga = item.manga
                                    } label: {
                                        iPadCollectionCard(item: item)
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            Task {
                                                await collectionVM.deleteManga(id: item.manga.id)
                                            }
                                        } label: {
                                            Label("Remove from Collection", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(collectionVM.collection) { item in
                                    Button {
                                        selectedManga = item.manga
                                    } label: {
                                        iPadCollectionRow(item: item)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("My Collection")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Picker("View Mode", selection: $viewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Image(systemName: mode.icon)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 100)
            }
        }
        .navigationDestination(item: $selectedManga) { manga in
            iPadMangaDetailView(manga: manga)
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

struct CollectionStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(title)
                    .secondaryText()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }
}

struct iPadCollectionCard: View {
    let item: UserMangaCollectionDTO

    private var progress: Double {
        guard let total = item.manga.volumes, total > 0 else { return 0 }
        return Double(item.volumesOwned.count) / Double(total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image with overlays
            CachedAsyncImage(url: item.manga.imageURL, width: .infinity, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(alignment: .bottom) {
                    // Progress overlay
                    VStack(spacing: 6) {
                        Spacer()

                        if let readingVolume = item.readingVolume {
                            Text("Reading Vol. \(readingVolume)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                        }

                        if let totalVolumes = item.manga.volumes, totalVolumes > 0 {
                            VStack(spacing: 3) {
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(.white.opacity(0.3))
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(item.completeCollection ? .green : .white)
                                            .frame(width: geo.size.width * progress)
                                    }
                                }
                                .frame(height: 6)

                                Text("\(item.volumesOwned.count)/\(totalVolumes)")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .overlay(alignment: .topTrailing) {
                    if item.completeCollection {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.green)
                            .background(Circle().fill(.white).padding(2))
                            .padding(8)
                    }
                }

            Text(item.manga.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                Text(item.manga.score.formatted(.number.precision(.fractionLength(2))))
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

struct iPadCollectionRow: View {
    let item: UserMangaCollectionDTO

    private var progress: Double {
        guard let total = item.manga.volumes, total > 0 else { return 0 }
        return Double(item.volumesOwned.count) / Double(total)
    }

    var body: some View {
        HStack(spacing: 16) {
            CachedAsyncImage(url: item.manga.imageURL, width: 80, height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 6) {
                Text(item.manga.title)
                    .font(.headline)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text(item.manga.score.formatted(.number.precision(.fractionLength(1))))
                }
                .subtitleStyle()

                Text(item.manga.status.displayName)
                    .badge(item.manga.status == .currentlyPublishing ? .green : .blue)

                if let volumes = item.manga.volumes {
                    Text("\(item.volumesOwned.count)/\(volumes) volumes")
                        .secondaryText()
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                if item.completeCollection {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                }

                if item.manga.volumes != nil {
                    ProgressView(value: progress)
                        .tint(item.completeCollection ? .green : .blue)
                        .frame(width: 100)
                }

                if let readingVolume = item.readingVolume {
                    Text("Reading Vol. \(readingVolume)")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
        }
        .card()
    }
}

#Preview {
    NavigationStack {
        iPadCollectionView()
    }
}
