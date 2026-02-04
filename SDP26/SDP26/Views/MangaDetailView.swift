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
    @State private var volumesOwned: Set<Int> = [1, 2, 3]
    @State private var readingVolume: Int? = 2

    private var imageURL: URL? {
        guard let picture = manga.mainPicture else { return nil }
        return URL(string: picture.trimmingCharacters(in: CharacterSet(charactersIn: "\"")))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerImage
                content
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerImage: some View {
        CachedAsyncImage(url: imageURL, width: UIScreen.main.bounds.width, height: 300)
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [.clear, Color(.systemBackground)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 100)
            }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            titleSection
            
            infoSection
            
            if let synopsis = manga.sypnosis, !synopsis.isEmpty {
                synopsisSection(synopsis)
            }
            
            
            tagsSection
        
          

           

            if let volumes = manga.volumes {
                collectionSection(count: volumes)
            }

            if !manga.authors.isEmpty {
                authorsSection
            }
            
             if let background = manga.background, !background.isEmpty {
                 backgroundSection(background)
             }
        }
        .padding()
        .background(Color(.systemBackground))
    }

    // MARK: - Title

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(manga.title)
                .font(.title2)
                .fontWeight(.bold)

            if let titleJapanese = manga.titleJapanese {
                Text(titleJapanese)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                Label(String(format: "%.1f", manga.score), systemImage: "star.fill")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.yellow)

                Text(manga.status.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(manga.status == .currentlyPublishing ? .green : .blue, in: Capsule())
            }
        }
    }

    // MARK: - Info Grid

    private var infoSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
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
    }

    // MARK: - Synopsis

    private func synopsisSection(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Synopsis")
                .font(.headline)

            Text(text)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Background

    private func backgroundSection(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Additional Information")
                .font(.headline)

            Text(text)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Authors

    private var authorsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Authors")
                .font(.headline)

            ForEach(manga.authors) { author in
                HStack(spacing: 12) {
                    Circle()
                        .fill(.blue.gradient)
                        .frame(width: 32, height: 32)
                        .overlay {
                            Text(author.firstName.prefix(1).uppercased())
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        }

                    VStack(alignment: .leading) {
                        Text(author.fullName)
                            .font(.subheadline)
                        Text(author.role.rawValue.capitalized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - My Collection

    private func collectionSection(count: Int) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("My Collection")
                    .font(.headline)

                Spacer()

                Text("\(volumesOwned.count)/\(count) volumes")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.secondary.opacity(0.2))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(.green)
                        .frame(width: geo.size.width * (Double(volumesOwned.count) / Double(count)))
                }
            }
            .frame(height: 8)

            // Volumes owned
            VStack(alignment: .leading, spacing: 8) {
                Text("Volumes owned")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 44, maximum: 50), spacing: 6)], spacing: 6) {
                    ForEach(1...count, id: \.self) { volume in
                        VolumeButton(
                            volume: volume,
                            isOwned: volumesOwned.contains(volume)
                        ) {
                            if volumesOwned.contains(volume) {
                                volumesOwned.remove(volume)
                                if readingVolume == volume { readingVolume = nil }
                            } else {
                                volumesOwned.insert(volume)
                            }
                        }
                    }
                }
            }

            Divider()

            // Reading progress
            VStack(alignment: .leading, spacing: 8) {
                Text("Currently reading")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if volumesOwned.isEmpty {
                    Text("Add volumes to your collection to track reading progress")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                } else {
                    VStack(spacing: 0) {
                        ReadingOptionRow(title: "None", isSelected: readingVolume == nil) {
                            readingVolume = nil
                        }

                        ForEach(Array(volumesOwned).sorted(), id: \.self) { volume in
                            Divider().padding(.leading, 44)
                            ReadingOptionRow(title: "Volume \(volume)", isSelected: readingVolume == volume) {
                                readingVolume = volume
                            }
                        }
                    }
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Tags

    private var tagsSection: some View {
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
    }
}

// MARK: - Supporting Views

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)

            Text(value)
                .font(.headline)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct TagRow: View {
    let title: String
    let tags: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.secondary.opacity(0.15), in: Capsule())
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

struct VolumeButton: View {
    let volume: Int
    let isOwned: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text("\(volume)")
                .font(.caption)
                .fontWeight(.semibold)
                .frame(width: 44, height: 36)
                .background(isOwned ? .green : .secondary.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
                .foregroundStyle(isOwned ? .white : .primary)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isOwned)
    }
}

struct ReadingOptionRow: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: isSelected ? "book.fill" : "book")
                    .foregroundStyle(isSelected ? .blue : .secondary)
                    .frame(width: 24)

                Text(title)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.blue)
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview("Full") {
    NavigationStack {
        MangaDetailView(manga: PreviewData.manga)
    }
}

#Preview("Minimal") {
    NavigationStack {
        MangaDetailView(manga: PreviewData.mangaSimple)
    }
}
