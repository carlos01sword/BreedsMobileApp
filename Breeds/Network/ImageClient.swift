import ComposableArchitecture
import SwiftUI

struct ImageClient {
    var fetchImage: @Sendable (_ id: String) async throws -> UIImage
}

extension ImageClient: DependencyKey {
    static let liveValue = ImageClient { id in

        if let cachedImage = await ImageCache.getCachedImage(for: id) {
            return cachedImage
        }

        do {
            let endpoint = await Endpoint.image(id: id)
            let data = try await NetworkClient.fetch(endpoint, isImage: true)

            let catImage = try JSONDecoder().decode(CatImage.self, from: data)
            guard let imageURL = URL(string: catImage.url) else {
                throw NetworkError.invalidURL
            }

            let (imageData, imageResponse) = try await URLSession.shared.data(from: imageURL)
            if let http = imageResponse as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                throw NetworkError.badStatus(http.statusCode)
            }

            guard let image = UIImage(data: imageData) else {
                throw NetworkError.decoding(NSError(domain: "InvalidImage", code: -1))
            }

            await ImageCache.setCachedImage(image, data: imageData, for: id)

            return image

        } catch {
            if let networkError = error as? NetworkError {
                throw networkError
            } else {
                throw NetworkError.transport(error)
            }
        }
    }
}

extension DependencyValues {
    var imageClient: ImageClient {
        get { self[ImageClient.self] }
        set { self[ImageClient.self] = newValue }
    }
}
