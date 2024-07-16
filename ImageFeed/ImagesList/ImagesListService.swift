import Foundation

final class ImagesListService{
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private (set) var photos: [Photo] = []
    private let networkClient = NetworkClient()
    private var lastLoadedPage: Int?
    private var currentTask : URLSessionTask?
    private let authToken = OAuth2TokenStorage().token ?? nil
    static let shared = ImagesListService()
    static var isoDateFormatter = ISO8601DateFormatter()
    private init() {}
   
    
    private func getRequestPhoto(_ authToken: String, page: Int) -> URLRequest?{
        guard let getUrl = URL(string: "https://api.unsplash.com/photos?per_page=10&page=\(page)") else {
            fatalError("Невозможно создать базовый URL")
        }
        var request = URLRequest(url: getUrl)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    func fetchPhotosNextPage(completion: (() -> Void)? = nil){
        assert(Thread.isMainThread)
        
        guard currentTask == nil else {
            print("Race Condition in fetchPhotosNextPage")
            return
        }
        
        guard let authToken else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = getRequestPhoto(authToken, page: nextPage) else{
            assertionFailure("Error Request")
            return
        }
        
        let session = networkClient.objectTask(for: request) {
            [weak self] (result: Result <[PhotoResult], Error>) in
            guard let self else { return }
            switch result {
            case .success(let photoResults):
                DispatchQueue.main.async{
                    var newPhotos: [Photo] = []
                    for photoResult in photoResults{
                        let newPhoto = Photo(
                            id: photoResult.id,
                            size: CGSize(width: photoResult.width, height: photoResult.height),
                            createdAt: ImagesListService.isoDateFormatter.date(from: photoResult.createdAt ?? ""),
                            welcomeDescription: photoResult.description ?? "",
                            thumbImageURL: photoResult.urls.thumb ?? nil,
                            largeImageURL: photoResult.urls.full ?? nil,
                            regularImageURL: photoResult.urls.regular ?? nil,
                            isLiked: photoResult.likedByUser)
                        newPhotos.append(newPhoto)
                    }
                    let uniquePhotos = newPhotos.filter { newPhoto in
                        !self.photos.contains(where: { existingPhoto in
                            return existingPhoto.id == newPhoto.id
                        })
                    }

                    self.photos += uniquePhotos
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                    self.lastLoadedPage = nextPage
                }
            case .failure(let error as NSError):
                print("[ImagesListService]: \(error.domain) - код ошибки \(error.code)")
            }
            self.currentTask = nil
        }
        currentTask = session
        session.resume()
    }
    
    private func postLikeOnPhoto(_ authToken: String, photoId: String, httpMethod: String) -> URLRequest?{
        guard let getUrl = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            fatalError("Невозможно создать базовый URL")
        }
        var request = URLRequest(url: getUrl)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = httpMethod
        return request
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Bool, Error>)->Void){
        assert(Thread.isMainThread)
        guard currentTask == nil else { return }
        
        guard let authToken else { return }
        
        guard let request = postLikeOnPhoto(authToken, photoId: photoId, httpMethod: isLike ? "DELETE" : "POST") else{
            assertionFailure("Error Request")
            return
        }
        
        let session = networkClient.objectTask(for: request) { [weak self] (result: Result<LikeResult, Error>) in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result{
                case .success(let photoLiked):
                    let likedByUser = photoLiked.photo.likedByUser
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            regularImageURL: photo.regularImageURL,
                            isLiked: !photo.isLiked
                        )
                        self.photos[index] = newPhoto
                    }
                    completion(.success(likedByUser))
                    self.currentTask = nil
                case .failure(let error as NSError):
                    print("[ImagesListService: change like]: \(error.domain) - код ошибки \(error.code)")
                    completion(.failure(error))
                }
            }
        }
        currentTask = session
        session.resume()
    }
    
    func resetPhotos() {
        photos = []
    }
}
