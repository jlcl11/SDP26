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

    private var imageURL: URL? {
        guard let picture = manga.mainPicture else { return nil }
        return URL(string: picture.trimmingCharacters(in: CharacterSet(charactersIn: "\"")))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {  // Cambia LazyVStack por VStack
                heroImage

                VStack(alignment: .leading, spacing: 16) {
                    titleSection
                    infoSection
                    if let sypnosis = manga.sypnosis, !sypnosis.isEmpty {
                        synopsisSection(sypnosis)
                    }
                    if !manga.authors.isEmpty {
                        authorsSection
                    }
                    tagsSection
                }
                .padding()
                .background(Color(uiColor: .systemBackground))  // Añade fondo
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .bottomBar)
    }

    private var heroImage: some View {
        HeroImage(url: imageURL)
            .frame(height: 350)
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [.clear, Color(uiColor: .systemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 60)
            }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(manga.title)
                .font(.title)
                .fontWeight(.bold)

            if let titleJapanese = manga.titleJapanese {
                Text(titleJapanese)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text(String(format: "%.1f", manga.score))
                        .fontWeight(.semibold)
                }

                Text(manga.status.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.blue.opacity(0.2), in: Capsule())
            }
        }
    }

    private var infoSection: some View {
        HStack(spacing: 24) {
            if let chapters = manga.chapters {
                InfoItem(title: "Chapters", value: "\(chapters)")
            }
            if let volumes = manga.volumes {
                InfoItem(title: "Volumes", value: "\(volumes)")
            }
            if let startDate = manga.startDate {
                InfoItem(title: "Started", value: startDate)
            }
        }
    }

    private func synopsisSection(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Synopsis")
                .font(.headline)
            Text(text)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var authorsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Authors")
                .font(.headline)
            ForEach(manga.authors) { author in
                HStack {
                    Text(author.fullName)
                    Spacer()
                    Text(author.role.rawValue.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
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

struct HeroImage: View {
    @State private var image: UIImage?
    let url: URL?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(.gray.opacity(0.3))
                    .overlay {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(.gray)
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .onAppear {
            guard let url else { return }
            Task {
                image = await ImageDownloader.shared.loadImage(url: url)
            }
        }
    }
}

struct InfoItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack {
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct TagRow: View {
    let title: String
    let tags: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            FlowLayout(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.gray.opacity(0.2), in: Capsule())
                }
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: currentY + lineHeight), positions)
    }
}

#Preview("Full Detail") {
    NavigationStack {
        MangaDetailView(manga: PreviewData.manga)
    }
}

#Preview("Minimal Detail") {
    NavigationStack {
        MangaDetailView(manga: PreviewData.mangaSimple)
    }
}
