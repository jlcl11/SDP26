//
//  BestMangasCaroussel.swift
//  SDP26
//
//  Created by José Luis Corral López on 3/2/26.
//

import SwiftUI

struct BestMangasCarousel: View {
    let mangas: [MangaDTO]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Best Mangas")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal) {
                LazyHStack(spacing: 12) {
                    ForEach(mangas) { manga in
                        NavigationLink(value: manga) {
                            MangaCard(manga: manga)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
        }
    }
}

struct MangaCard: View {
    let manga: MangaDTO

    private var imageURL: URL? {
        guard let picture = manga.mainPicture else { return nil }
        return URL(string: picture.trimmingCharacters(in: CharacterSet(charactersIn: "\"")))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
         CachedAsyncImage(url: imageURL,width: 100, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(manga.title)
                .font(.caption)
                .lineLimit(1)

            Text(manga.score.formatted(.number.precision(.fractionLength(2))))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(width: 100)
    }
}

#Preview("With Mangas") {
    NavigationStack {
        BestMangasCarousel(mangas: PreviewData.mangas)
    }
}

#Preview("Empty") {
    BestMangasCarousel(mangas: [])
}
