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
            Label("Best Mangas", systemImage: "star.fill")
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

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            CachedAsyncImage(url: manga.imageURL, width: 100, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(manga.title)
                .cardTitle()

            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                Text(manga.score.formatted(.number.precision(.fractionLength(2))))
            }
            .secondaryText()
        }
        .frame(width: 100)
    }
}

#Preview("Carousel") {
    NavigationStack {
        BestMangasCarousel(mangas: PreviewData.mangas)
    }
}

#Preview("Card") {
    MangaCard(manga: PreviewData.manga)
        .padding()
}
