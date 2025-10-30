import Foundation

public enum Environment {
    enum Keys{
        static let apiKey = "API_KEY"
        static let urlHost = "URL_HOST"
        static let urlPath = "URL_PATH"
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict  = Bundle.main.infoDictionary else {
            fatalError("plist file not found")
        }
        return dict
    }()
    
    static let urlHost: String = {
        guard let urlHostString = Environment.infoDictionary[Keys.urlHost] as? String else {
            fatalError("URL Host not found in plist")
        }
        return urlHostString
    }()
    
    static let urlPath: String = {
        guard let urlPathString = Environment.infoDictionary[Keys.urlPath] as? String else {
            fatalError("URL Path not found in plist")
        }
        return urlPathString
    }()
    
    static let apiKey: String = {
        guard let apiKeyString = Environment.infoDictionary[Keys.apiKey] as? String else {
            fatalError("Api Key not found in plist")
        }
        return apiKeyString
    }()
}
