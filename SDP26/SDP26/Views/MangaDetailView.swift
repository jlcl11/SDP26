//
//  MangaDetailView.swift
//  SDP26
//
//  Created by José Luis Corral López on 2/2/26.
//

import SwiftUI
import NetworkAPI

struct MangaDetailView: View {
    let manga: MangaDTO

    @State private var collectionVM = CollectionVM.shared
    @State private var volumesOwned: Set<Int> = []
    @State private var readingVolume: Int?
    @State private var isSaving = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header Image
                CachedAsyncImage(url: manga.imageURL, width: .infinity, height: 500)
                    .overlay(alignment: .bottom) {
                        LinearGradient(
                            colors: [.clear, Color(.systemBackground)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .frame(height: 100)
                    }

                // Content
                VStack(alignment: .leading, spacing: 20) {
                    // Title & Status
                    VStack(alignment: .leading, spacing: 8) {
                        Text(manga.title)
                            .font(.title2)
                            .fontWeight(.bold)

                        if let titleJapanese = manga.titleJapanese {
                            Text(titleJapanese).subtitleStyle()
                        }

                        Text(manga.status.displayName)
                            .badge(manga.status == .currentlyPublishing ? .green : .blue)

                        Label(manga.score.formatted(.number.precision(.fractionLength(2))), systemImage: "star.fill")
                            .scoreStyle()
                    }

                    // Info Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        if let chapters = manga.chapters {
                            InfoCard(title: "Chapters", value: "\(chapters)", icon: "book.pages")
                        }
                        if let volumes = manga.volumes {
                            InfoCard(title: "Volumes", value: "\(volumes)", icon: "books.vertical")
                        }
                        if let startDate = manga.startDate {
                            InfoCard(title: "Started", value: startDate.formatted(date: .abbreviated, time: .omitted), icon: "calendar")
                        }
                        if let endDate = manga.endDate {
                            InfoCard(title: "Ended", value: endDate.formatted(date: .abbreviated, time: .omitted), icon: "calendar.badge.checkmark")
                        }
                    }

                    // Synopsis
                    if let synopsis = manga.sypnosis, !synopsis.isEmpty {
                        Text(synopsis)
                            .foregroundStyle(.secondary)
                            .sectionHeader("Synopsis")
                    }

                    // Tags
                    VStack(alignment: .leading, spacing: 16) {
                        if !manga.genres.isEmpty {
                            TagRow(title: "Genres", tags: manga.genres.map(\.genre))
                        }
                        if !manga.themes.isEmpty {
                            TagRow(title: "Themes", tags: manga.themes.map(\.theme))
                        }
                        if !manga.demographics.isEmpty {
                            TagRow(title: "Demographics", tags: manga.demographics.map(\.demographic.rawValue))
                        }
                    }

                    // Collection
                    if let volumes = manga.volumes {
                        MangaCollectionCard(
                            totalVolumes: volumes,
                            volumesOwned: $volumesOwned,
                            readingVolume: $readingVolume
                        )
                    }

                    // Authors
                    if !manga.authors.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(manga.authors) { author in
                                NavigationLink(value: author) {
                                    HStack(spacing: 12) {
                                        Text(author.firstName.prefix(1).uppercased()).avatar()

                                        VStack(alignment: .leading) {
                                            Text(author.fullName).font(.subheadline)
                                            Text(author.role.rawValue.capitalized).secondaryText()
                                        }

                                        Spacer()


                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .sectionHeader("Authors")
                    }

                    // Additional Information
                    if let background = manga.background, !background.isEmpty {
                        Text(background)
                            .foregroundStyle(.secondary)
                            .sectionHeader("Additional Information")
                    }
                }
                .padding()
                .background(Color(.systemBackground))
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: AuthorDTO.self) { author in
            AuthorDetailView(author: author)
        }
        .task {
            await loadCollectionStatus()
        }
        .onChange(of: volumesOwned) { _, _ in
            Task { await saveCollection() }
        }
        .onChange(of: readingVolume) { _, _ in
            Task { await saveCollection() }
        }
    }

    // MARK: - Collection Methods

    private func loadCollectionStatus() async {
        // Ensure collection is loaded
        if collectionVM.collection.isEmpty {
            await collectionVM.loadCollection()
        }

        // Find this manga in the collection
        if let item = collectionVM.getItem(for: manga.id) {
            volumesOwned = Set(item.volumesOwned)
            readingVolume = item.readingVolume
        }
    }

    private func saveCollection() async {
        guard !isSaving else { return }
        isSaving = true

        let request = UserMangaCollectionRequest(
            volumesOwned: volumesOwned.sorted(),
            completeCollection: volumesOwned.count >= (manga.volumes ?? 0),
            manga: manga.id,
            readingVolume: readingVolume
        )

        await collectionVM.addOrUpdateManga(request)
        isSaving = false
    }
}

#Preview {
    NavigationStack {
        MangaDetailView(manga: PreviewData.manga)
    }
}
