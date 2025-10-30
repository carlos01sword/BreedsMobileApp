import ComposableArchitecture
import Foundation

struct BreedsClient {
    var fetchBreeds: @Sendable () async throws -> [Breed]
}

extension BreedsClient: DependencyKey {
    static let liveValue = BreedsClient {
        do {
            let data = try await NetworkClient.fetch(from: "/breeds")
            do {
                return try JSONDecoder().decode([Breed].self, from: data)
            } catch {
                throw NetworkError.decoding(error)
            }
        } catch {
            if let netErr = error as? NetworkError {
                throw netErr
            } else {
                throw NetworkError.transport(error)
            }
        }
    }
}


extension DependencyValues {
    var breedsClient: BreedsClient {
        get { self[BreedsClient.self] }
        set { self[BreedsClient.self] = newValue }
    }
}
