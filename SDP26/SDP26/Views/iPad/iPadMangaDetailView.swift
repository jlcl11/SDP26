//
//  iPadMangaDetailView.swift
//  SDP26
//
//  Created by José Luis Corral López on 6/2/26.
//

import SwiftUI

struct iPadMangaDetailView: View {
    let manga: MangaDTO

    @State private var collectionVM = CollectionVM.shared
    @State private var volumesOwned: Set<Int> = []
    @State private var readingVolume: Int?
    @State private var saveTask: Task<Void, Never>?
    @State private var selectedAuthor: AuthorDTO?

    var body: some View {
        ScrollView {
            HStack(alignment: .top, spacing: 40) {
                // Left Column - Image & Quick Info
                VStack(spacing: 20) {
                    CachedAsyncImage(url: manga.imageURL, width: 300, height: 420)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)

                    // Quick Stats
                    VStack(spacing: 12) {
                        Label(manga.score.formatted(.number.precision(.fractionLength(2))), systemImage: "star.fill")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.yellow)

                        Text(manga.status.displayName)
                            .badge(manga.status == .currentlyPublishing ? .green : .blue)
                    }

                    // Info Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        if let chapters = manga.chapters {
                            StatCard(title: "Chapters", value: "\(chapters)", icon: "book.pages")
                        }
                        if let volumes = manga.volumes {
                            StatCard(title: "Volumes", value: "\(volumes)", icon: "books.vertical")
                        }
                        if let startDate = manga.startDate {
                            StatCard(title: "Started", value: startDate.formatted(date: .abbreviated, time: .omitted), icon: "calendar")
                        }
                        if let endDate = manga.endDate {
                            StatCard(title: "Ended", value: endDate.formatted(date: .abbreviated, time: .omitted), icon: "calendar.badge.checkmark")
                        }
                    }
                }
                .frame(width: 300)

                // Right Column - Details
                VStack(alignment: .leading, spacing: 24) {
                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text(manga.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        if let titleJapanese = manga.titleJapanese {
                            Text(titleJapanese)
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Synopsis
                    if let synopsis = manga.sypnosis, !synopsis.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Synopsis")
                                .font(.headline)

                            Text(synopsis)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Tags in horizontal layout
                    HStack(alignment: .top, spacing: 32) {
                        if !manga.genres.isEmpty {
                            TagColumn(title: "Genres", tags: manga.genres.map(\.genre))
                        }
                        if !manga.themes.isEmpty {
                            TagColumn(title: "Themes", tags: manga.themes.map(\.theme))
                        }
                        if !manga.demographics.isEmpty {
                            TagColumn(title: "Demographics", tags: manga.demographics.map(\.demographic.rawValue))
                        }
                    }

                    // Authors
                    if !manga.authors.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Authors")
                                .font(.headline)

                            HStack(spacing: 16) {
                                ForEach(manga.authors) { author in
                                    Button {
                                        selectedAuthor = author
                                    } label: {
                                        HStack(spacing: 12) {
                                            Text(author.firstName.prefix(1).uppercased())
                                                .avatar(size: 40)

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(author.fullName)
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                Text(author.role.rawValue)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        .padding(12)
                                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    // Collection Card
                    if let volumes = manga.volumes {
                        MangaCollectionCard(
                            totalVolumes: volumes,
                            volumesOwned: $volumesOwned,
                            readingVolume: $readingVolume
                        )
                    }

                    // Additional Info
                    if let background = manga.background, !background.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Additional Information")
                                .font(.headline)

                            Text(background)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(32)
        }
        .navigationTitle(manga.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedAuthor) { author in
            iPadAuthorDetailView(author: author)
        }
        .task {
            await loadCollectionStatus()
        }
        .onChange(of: volumesOwned) { _, _ in
            scheduleCollectionSave()
        }
        .onChange(of: readingVolume) { _, _ in
            scheduleCollectionSave()
        }
    }

    // MARK: - Collection Methods

    private func loadCollectionStatus() async {
        if collectionVM.collection.isEmpty {
            await collectionVM.loadCollection()
        }

        if let item = collectionVM.getItem(for: manga.id) {
            volumesOwned = Set(item.volumesOwned)
            readingVolume = item.readingVolume
        }
    }

    private func scheduleCollectionSave() {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await saveCollection()
        }
    }

    private func saveCollection() async {
        let request = UserMangaCollectionRequest(
            volumesOwned: volumesOwned.sorted(),
            completeCollection: volumesOwned.count >= (manga.volumes ?? 0),
            manga: manga.id,
            readingVolume: readingVolume
        )
        await collectionVM.addOrUpdateManga(request)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)

            Text(title)
                .secondaryText()
        }
        .statCard()
    }
}

struct TagColumn: View {
    let title: String
    let tags: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            FlowLayout(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .tagStyle()
                }
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > width, x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: width, height: y + rowHeight)
        }
    }
}

#Preview {
    NavigationStack {
        iPadMangaDetailView(manga: PreviewData.manga)
    }
}
