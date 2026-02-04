//
//  CachedAsyncImage.swift
//  SDP26
//
//  Created by José Luis Corral López on 2/2/26.
//

import SwiftUI
import NetworkAPI

struct CachedAsyncImage: View {
    @State private var image: UIImage?

    let url: URL?
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
            } else {
                Rectangle()
                    .fill(.secondary.opacity(0.2))
                    .frame(width: width, height: height)
            }
        }
        .task(id: url) {
            guard let url else { return }

            // 1. Check disk cache first (fastest)
            let fileURL = ImageDownloader.shared.getFileURL(url: url)
            if FileManager.default.fileExists(atPath: fileURL.path()),
               let data = try? Data(contentsOf: fileURL),
               let cachedImage = UIImage(data: data) {
                image = cachedImage
                return
            }

            // 2. Download and cache
            image = await ImageDownloader.shared.loadImage(url: url)
        }
    }
}

#Preview("With URL") {
    CachedAsyncImage(
        url: URL(string: "https://cdn.myanimelist.net/images/manga/1/157897l.jpg"),
        width: 100,
        height: 150
    )
}

#Preview("Without URL") {
    CachedAsyncImage(url: nil, width: 100, height: 150)
}
