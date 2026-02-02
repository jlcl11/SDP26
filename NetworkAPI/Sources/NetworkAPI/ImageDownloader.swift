//
//  ImageDownloader.swift
//  EmpleadosAPI
//
//  Created by Julio César Fernández Muñoz on 20/11/25.
//

import SwiftUI

public actor ImageDownloader {
    public static let shared = ImageDownloader()
    
    private enum ImageStatus {
        case downloading(task: Task<UIImage, any Error>)
        case downloaded(image: UIImage)
    }
    
    private var cache: [URL: ImageStatus] = [:]
    
    private func getImage(url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let image = UIImage(data: data) {
            return image
        } else {
            throw URLError(.badServerResponse)
        }
    }
    
    public func image(for url: URL) async throws -> UIImage {
        if let status = cache[url] {
            return switch status {
            case .downloading(let task):
                try await task.value
            case .downloaded(let image):
                image
            }
        }
        
        let task = Task {
            try await getImage(url: url)
        }
        
        cache[url] = .downloading(task: task)
        
        do {
            let image = try await task.value
            cache[url] = .downloaded(image: image)
            // Guardar la imagen en disco
            return image
        } catch {
            cache.removeValue(forKey: url)
            throw error
        }
    }
    
    
    func saveImage(url: URL) async throws {
        guard let imageCached = cache[url],
              case .downloaded(let image) = imageCached else { return }
        if let resized = await image.resize(width: 300),
           let data = resized.pngData() {
            try data.write(to: getFileURL(url: url),
                           options: .atomic)
            cache.removeValue(forKey: url)
        }
    }

    nonisolated public func getFileURL(url: URL) -> URL {
        URL.cachesDirectory.appending(path: url.lastPathComponent)
    }

    public func loadImage(url: URL) async -> UIImage? {
        let file = getFileURL(url: url)
        if FileManager.default.fileExists(atPath: file.path()) {
            if let data = try? Data(contentsOf: file) {
                return UIImage(data: data)
            }
        }
        return try? await image(for: url)
    }
}
