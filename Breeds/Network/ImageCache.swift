import SwiftUI

enum ImageCache {
    private static let memoryCache = NSCache<NSString, UIImage>()
    private static let fileManager = FileManager.default
    private static let cacheDirectory: URL = {
        let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ImageCache", isDirectory: true)
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }()

    static func getCachedImage(for id: String?) -> UIImage? {
        guard let id = id else { return nil }
        let key = id as NSString

        if let cached = memoryCache.object(forKey: key) {
            return cached
        }

        let fileURL = cacheDirectory.appendingPathComponent(id)
        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data)
        else {
            return nil
        }

        memoryCache.setObject(image, forKey: key)
        return image
    }

    static func setCachedImage(_ image: UIImage, data: Data? = nil, for id: String) {
        let key = id as NSString
        memoryCache.setObject(image, forKey: key)

        let fileURL = cacheDirectory.appendingPathComponent(id)
        if let data = data ?? image.pngData() {
            try? data.write(to: fileURL)
        }
    }
}
