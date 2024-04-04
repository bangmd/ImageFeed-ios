import Foundation

protocol OAuth2TokenProtocol{
    var token: String? { get }
}

final class OAuth2TokenStorage: OAuth2TokenProtocol{
    private enum Keys: String {
        case token
    }
    
    private let userDefaults = UserDefaults.standard
    
    var token: String?{
        get {
            userDefaults.string(forKey: Keys.token.rawValue)
        }
        set{
            userDefaults.setValue(newValue, forKey: Keys.token.rawValue)
        }
    }
}
