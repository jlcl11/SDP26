//
//  MangaRow.swift
//  SDP26
//
//  Created by José Luis Corral López on 2/2/26.
//

import SwiftUI

struct MangaRow: View {
    let manga: MangaDTO

    var body: some View {
        HStack(spacing: 12) {
            CachedAsyncImage(url: manga.imageURL, width: 60, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(manga.title)
                    .rowTitle()

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text(manga.score.formatted(.number.precision(.fractionLength(2))))
                }
                .secondaryText()

                Text(manga.status.displayName)
                    .badge(manga.status == .currentlyPublishing ? .green : .blue)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        MangaRow(manga: PreviewData.manga)
        MangaRow(manga: PreviewData.mangaSimple)
    }
    .listStyle(.plain)
}
