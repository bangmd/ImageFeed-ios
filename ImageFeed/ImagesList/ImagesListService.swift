import Foundation

final class ImagesListService{
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private (set) var photos: [Photo] = []
    private let networkClient = NetworkClient()
    private var lastLoadedPage: Int?
    private var currentTask : URLSessionTask?
    
    
    private func getRequestPhoto(_ authToken: String, page: Int) -> URLRequest?{
        guard let getUrl = URL(string: "https://api.unsplash.com/photos?per_page=10&page=\(page)") else {
            fatalError("Невозможно создать базовый URL")
        }
        var request = URLRequest(url: getUrl)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    
    func fetchPhotosNextPage(_ authToken: String?, handler: @escaping (Result<[Photo], Error>) -> Void){
        assert(Thread.isMainThread)
        
        guard currentTask == nil else {
            print("Race Condition in fetchPhotosNextPage")
            return
        }
        
        guard let authToken else { return }
        
        let nextPage = (lastLoadedPage ?? 0 ) + 1
        guard let request = getRequestPhoto(authToken, page: nextPage) else{
            assertionFailure("Error Request")
            handler(.failure(NetworkError.invalidRequest))
            return
        }
        
        let session = networkClient.objectTask(for: request) {
            (result: Result <[PhotoResult], Error>) in
            switch result {
            case .success(let photoResults):
                DispatchQueue.main.async{
                    for photoResult in photoResults{
                        let newPhoto = Photo(
                            id: photoResult.id,
                            size: CGSize(width: photoResult.width, height: photoResult.height),
                            createdAt: ISO8601DateFormatter().date(from: photoResult.createdAt ?? ""),
                            welcomeDescription: photoResult.description ?? "",
                            thumbImageURL: photoResult.urls.thumb ?? "",
                            largeImageURL: photoResult.urls.full ?? "",
                            isLiked: photoResult.likedByUser)
                        self.photos.append(newPhoto)
                    }
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                    self.lastLoadedPage = nextPage
                    handler(.success(self.photos))
                }
            case .failure(let error as NSError):
                print("[ImagesListService]: \(error.domain) - код ошибки \(error.code)")
                handler(.failure(error))
            }
        }
        currentTask = session
        session.resume()
    }
    
    
}
