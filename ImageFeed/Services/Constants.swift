import Foundation

enum Constants{
    static let accessKey = "ZS5WdPjFnsNl6KV5nqED5GSDGbjNgP7w7-LgfKyJtn0"
    static let secretKey = "XV-loRpViMFgxVl8fJ3YeJBnaJIDG8DcNs3X4bxAz1A"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}
