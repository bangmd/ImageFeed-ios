import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: URL?
    let largeImageURL: URL?
    let regularImageURL: URL?
    var isLiked: Bool
}

struct PhotoResult: Codable{
    let id: String
    let width, height: Int
    let createdAt: String?
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey{
        case id, width, height, description, urls
        case createdAt = "created_at"
        case likedByUser = "liked_by_user"
    }
}

struct UrlsResult: Codable{
    let full: URL?
    let thumb: URL?
    let regular: URL?
}

struct LikeResult: Codable {
    let photo: PhotoResult
}
