import Foundation
import SwiftKeychainWrapper

protocol OAuth2TokenProtocol{
    var token: String? { get }
}

final class OAuth2TokenStorage: OAuth2TokenProtocol{
    private enum Keys: String {
        case token
    }
    
    var token: String?{
        get {
            KeychainWrapper.standard.string(forKey: Keys.token.rawValue)
        }
        set{
            guard let newValue = newValue else { return }
            KeychainWrapper.standard.set(newValue, forKey: Keys.token.rawValue)
        }
    }
}

extension OAuth2TokenStorage{
    func removeToken() -> Bool{
        KeychainWrapper.standard.removeObject(forKey: Keys.token.rawValue)
    }
}
