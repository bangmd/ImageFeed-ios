import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let regularImageURL: String
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
    let full: String?
    let thumb: String?
    let regular: String?
}

struct LikeResult: Codable {
    let photo: PhotoResult
}
