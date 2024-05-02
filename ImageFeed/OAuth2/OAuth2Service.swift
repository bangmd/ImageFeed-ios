import Foundation

final class OAuth2Service {
    private let urlSession = URLSession.shared
    private let networkClient = NetworkClient()
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    init(task: URLSessionTask? = nil, lastCode: String? = nil) {
        self.task = task
        self.lastCode = lastCode
    }
    
    private (set) var authToken: String?{
        get{
            return OAuth2TokenStorage().token
        }
        set{
            OAuth2TokenStorage().token = newValue
        }
    }
    
    func makeOAuthTokenRequest(code: String) -> URLRequest?{
        guard let baseUrl = URL(string: "https://unsplash.com") else {
            fatalError("Невозможно создать базовый URL")
        }
        
        guard let url = URL(
            string: "\(baseUrl)"
            + "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code") else {
            fatalError("Невозможно создать URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    
    func fetchOAuthTokenResponseBody(with code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else{
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            assertionFailure("Error Reguest")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task = networkClient.objectTask(for: request) {
            (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let body):
                let authToken = body.accessToken
                self.authToken = authToken
                completion(.success(authToken))
                self.lastCode = nil
                self.task = nil
            case .failure(let error as NSError):
                self.lastCode = nil
                print("[ProfileService]: \(error.domain) - код ошибки \(error.code)")
                completion(.failure(error))
            }
        }
        task?.resume()
    }
}
