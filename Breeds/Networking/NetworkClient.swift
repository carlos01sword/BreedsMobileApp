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

struct NetworkClient {
    static func fetch(from path: String) async throws -> Data {
        let base = Environment.baseURL.replacingOccurrences(of: "\\/", with: "/")
        guard let url = URL(string: "\(base)/v1\(path)") else {
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
