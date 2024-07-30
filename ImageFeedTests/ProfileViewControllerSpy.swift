import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol{
    var presenter: ImageFeed.ProfileViewPresenterProtocol?
    
    func showAvatar(url: URL) {
        
    }
    
    func updateProfileDetails(name: String, loginName: String, bio: String) {
        
    }
    
    func resetProfileView() {
        
    }
}
