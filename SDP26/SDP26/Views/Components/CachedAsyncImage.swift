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
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)
            }
        }
        .onAppear {
            guard let url else { return }
            Task {
                image = await ImageDownloader.shared.loadImage(url: url)
            }
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
