import Foundation

final class ProfileService{
    private let storage = OAuth2TokenStorage()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    static let shared = ProfileService()
    private(set) var profile: Profile?
    
    private init() {}
    func makeGetRequest(_ authToken: String) -> URLRequest{
        guard let getUrl = URL(string: "https://api.unsplash.com/me") else {
            fatalError("Невозможно создать базовый URL")
        }
        
        var request = URLRequest(url: getUrl)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetchProfile(_ authToken: String?, handler: @escaping (Result<Profile, Error>) -> Void){
        assert(Thread.isMainThread)
        
        guard let authToken else { return }
        let request = makeGetRequest(authToken)
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
                let response = try JSONDecoder().decode(ProfileResult.self, from: data)
                DispatchQueue.main.async {
                    let profile = Profile(decodedData: response)
                    self.profile = profile
                    handler(.success(profile))
                }
            }catch let dataError{
                DispatchQueue.main.async {
                    handler(.failure(dataError))
                }
            }
        }
        session.resume()
    }
}
