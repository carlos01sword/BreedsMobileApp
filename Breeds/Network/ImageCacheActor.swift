import ComposableArchitecture
import SwiftUI

public actor ImageCacheActor {
    static let shared = ImageCacheActor()

    private let imageCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL = {
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ImageCache", isDirectory: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        return url
    }()

    private func filePath(for id: String) -> URL {
        cacheDirectory.appendingPathComponent(id)
    }

    // Function to check the cache
    func image(for id: String) -> UIImage? {
        let cacheKey = id as NSString

        // Check in-memory
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            return cachedImage
        }

        // Check on-disk
        let fileURL = filePath(for: id)
        if fileManager.fileExists(atPath: fileURL.path),
           let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            // Store in-memory for next time
            imageCache.setObject(image, forKey: cacheKey)
            return image
        }

        // Not found
        return nil
    }

    // Save a newly fetched image
    func setImage(_ image: UIImage, data: Data, for id: String) {
        let cacheKey = id as NSString

        // Save to in-memory
        imageCache.setObject(image, forKey: cacheKey)

        // Save to disk
        let fileURL = filePath(for: id)
        try? data.write(to: fileURL)
    }
}

