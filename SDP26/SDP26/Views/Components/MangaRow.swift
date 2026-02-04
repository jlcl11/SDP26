//
//  MangaRow.swift
//  SDP26
//
//  Created by José Luis Corral López on 2/2/26.
//

import SwiftUI

struct MangaRow: View {
    let manga: MangaDTO

    private var imageURL: URL? {
        guard let picture = manga.mainPicture else { return nil }
        return URL(string: picture.trimmingCharacters(in: CharacterSet(charactersIn: "\"")))
    }

    var body: some View {
        HStack {
            CachedAsyncImage(url: imageURL, width: 75, height: 75)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 4) {
                Text(manga.title)
                    .font(.headline)
                    .lineLimit(1)

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption)
                        Text(manga.score.formatted(.number.precision(.fractionLength(2))))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                
                Text(manga.status.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview("With Image") {
    List {
        MangaRow(manga: PreviewData.manga)
    }
}

#Preview("Without Image") {
    List {
        MangaRow(manga: PreviewData.mangaSimple)
    }
}
