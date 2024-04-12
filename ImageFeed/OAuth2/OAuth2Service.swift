import Foundation

final class OAuth2Service {
    private let urlSession = URLSession.shared
    
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
    
    func makeOAuthTokenRequest(code: String) -> URLRequest{
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
        
    
  
    private enum NetworkError: Error {
        case codeError
    }
    
    enum AuthServiceError: Error {
        case invalidRequest
    }
    
    func fetchOAuthTokenResponseBody(with code: String, handler: @escaping (Result<String, Error>) -> Void){
        assert(Thread.isMainThread)
        guard lastCode != code else{
            handler(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        
        let request = makeOAuthTokenRequest(code: code)
        let session = urlSession.dataTask(with: request) { data, response, error in
            if let error = error{
                DispatchQueue.main.async {
                    handler(.failure(error))
                }
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                DispatchQueue.main.async {
                    handler(.failure(NetworkError.codeError))
                }
                return
            }
            
            guard let data = data else { return }
            do {
                let responseBody = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                DispatchQueue.main.async {
                    let authToken = responseBody.accessToken
                    self.authToken = authToken
                    handler(.success(authToken))
                    self.task = nil
                    self.lastCode = nil
                }
            }catch let  dataError{
                DispatchQueue.main.async {
                    handler(.failure(dataError))
                }
            }
        }
        self.task = session
        session.resume()
    }
}
