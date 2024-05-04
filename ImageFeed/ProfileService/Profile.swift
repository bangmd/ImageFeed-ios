import Foundation

struct Profile{
    let username: String
    let name: String
    let loginName: String
    let bio: String 
    
    init(decodedData: ProfileResult) {
        self.username = decodedData.username
        self.name = "\(decodedData.firstName) \(decodedData.lastName ?? "")"
        self.loginName = "@" + decodedData.username
        self.bio = decodedData.bio ?? ""
    }
}
