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
            Text(manga.title)
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
