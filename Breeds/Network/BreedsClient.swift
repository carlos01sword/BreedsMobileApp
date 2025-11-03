import ComposableArchitecture
import Foundation

struct BreedsClient {
    var fetchBreeds: @Sendable () async throws -> [Breed]
}

extension BreedsClient: DependencyKey {
    static let liveValue = BreedsClient {
        do {
            let data = try await NetworkClient.fetch(.breeds)
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return (try decoder.decode([BreedDTO].self, from: data)).map(\.breed)
            } catch {
                throw NetworkError.decoding(error)
            }
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
    var breedsClient: BreedsClient {
        get { self[BreedsClient.self] }
        set { self[BreedsClient.self] = newValue }
    }
}
