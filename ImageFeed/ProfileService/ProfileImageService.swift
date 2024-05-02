import Foundation

final class ProfileImageService{
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private (set) var avatarURL: String?
    private let profileService = ProfileService.shared
    private let networkClient = NetworkClient()
    static let shared = ProfileImageService()
    private init() { }
    
    private func makeGetPhotoRequest(_ authToken: String) -> URLRequest?{
        let username = profileService.profile?.username
        
        guard let getUrl = URL(string: "https://api.unsplash.com/users/\(username ?? "")") else {
            fatalError("Невозможно создать базовый URL")
        }
        
        var request = URLRequest(url: getUrl)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    
    func fetchProfileImageURL(_ authToken: String?, handler: @escaping (Result<String, Error>) -> Void){
        guard let authToken else { return }
        guard let request = makeGetPhotoRequest(authToken) else{
            assertionFailure("Error request")
            handler(.failure(NetworkError.invalidRequest))
            return
        }

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
            case .failure(let error as NSError):
                DispatchQueue.main.async {
                    print("[ProfileImageService]: \(error.domain) - код ошибки \(error.code)")
                    handler(.failure(error))
                }
            }
        }
        
        session.resume()
    }
        
}

