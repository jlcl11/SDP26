//
//  SharedImageCache.swift
//  SDP26
//
//  Manages image caching in the App Group container
//  so both the main app and widget can access cached images.
//

import SwiftUI
import CryptoKit

actor SharedImageCache {
    static let shared = SharedImageCache()

    private let appGroupIdentifier = "group.prueba.offi"

    private init() {}

    /// Gets the cache directory URL
    private nonisolated var cacheDirectoryURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)?
            .appendingPathComponent("ImageCache", isDirectory: true)
    }

    /// Creates a stable hash for a URL (consistent across processes)
    private nonisolated func stableHash(for url: URL) -> String {
        let data = Data(url.absoluteString.utf8)
        let hash = SHA256.hash(data: data)
        return hash.prefix(16).map { String(format: "%02x", $0) }.joined()
    }

    /// Gets the file URL for a cached image
    nonisolated func fileURL(for imageURL: URL) -> URL? {
        guard let dir = cacheDirectoryURL else { return nil }

        // Create directory if needed
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        // Use stable SHA256 hash as filename (consistent across app and widget)
        let filename = "\(stableHash(for: imageURL)).png"
        return dir.appendingPathComponent(filename)
    }

    /// Saves an image to the shared cache
    func saveImage(_ image: UIImage, for url: URL) {
        guard let fileURL = fileURL(for: url) else { return }

        // Resize image for widget (smaller size to save space)
        let targetSize = CGSize(width: 150, height: 210)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        if let data = resized.pngData() {
            try? data.write(to: fileURL, options: Data.WritingOptions.atomic)
        }
    }

    /// Loads an image from the shared cache
    nonisolated func loadImage(for url: URL) -> UIImage? {
        guard let fileURL = fileURL(for: url),
              FileManager.default.fileExists(atPath: fileURL.path()) else {
            return nil
        }

        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }

        return UIImage(data: data)
    }
}
