import Foundation

enum NetworkError: Error, CustomStringConvertible {
    case invalidURL
    case badStatus(Int)
    case decoding(Error)
    case transport(Error)

    var description: String {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .badStatus(let code): return "Bad status code: \(code)"
        case .decoding(let err): return "Decoding error: \(err.localizedDescription)"
        case .transport(let err): return "Network error: \(err.localizedDescription)"
        }
    }
}

struct Endpoint {
    let path: String
    var fetchBreedsUrl: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Environment.urlHost
        components.path = "/v1" + path
        return components.url
    }
}

extension Endpoint {
    static var breeds: Endpoint {
        Endpoint(path: Environment.urlPath)
    }
}

struct NetworkClient {
    static func fetch(_ endpoint: Endpoint) async throws -> Data {
        guard let url = endpoint.fetchBreedsUrl else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.setValue(Environment.apiKey, forHTTPHeaderField: "x-api-key")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                throw NetworkError.badStatus(http.statusCode)
            }
            return data
        } catch {
            throw NetworkError.transport(error)
        }
    }
}
