import Foundation

final class ProfileImageService{
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private (set) var avatarURL: String?
    private let profileService = ProfileService.shared
    private let networkClient = NetworkClient()
    static let shared = ProfileImageService()
    private init() { }
    
    func makeGetPhotoRequest(_ authToken: String) -> URLRequest{
        let username = profileService.profile?.username
        
        guard let getUrl = URL(string: "https://api.unsplash.com/users/\(username ?? "")") else {
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
    
    func fetchProfileImageURL(_ authToken: String?, handler: @escaping (Result<String, Error>) -> Void){
        guard let authToken else { return }
        let request = makeGetPhotoRequest(authToken)

        let session = networkClient.objectTask(for: request) {
            (result: Result <UserResult, Error>) in
            switch result {
            case .success(let body):
                DispatchQueue.main.async {
                    self.avatarURL = body.profileImage?.large ?? ""
                    handler(.success(self.avatarURL ?? ""))
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": self.avatarURL])
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    handler(.failure(error))
                }
            }
        }
        
        session.resume()
    }
        
}

