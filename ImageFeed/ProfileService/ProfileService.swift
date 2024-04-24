import Foundation

final class ProfileService{
    private let networkClient = NetworkClient()
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
        
        task = networkClient.objectTask(for: request) {
            (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let body):
                DispatchQueue.main.async {
                    let profile = Profile(decodedData: body)
                    self.profile = profile
                    handler(.success(profile))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    handler(.failure(error))
                }
            }
        }
        task?.resume()
    }
}
