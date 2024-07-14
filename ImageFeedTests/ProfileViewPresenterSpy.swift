import ImageFeed

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol{
    var view: ImageFeed.ProfileViewControllerProtocol?
    var updateProfileAvatar: Bool = false
    var updateProfileData: Bool = false
    var removeAllDataWhileExit: Bool = false
    
    func viewDidLoad() {
        
    }
    
    func updateDataAvatar() {
        updateProfileAvatar = true
    }
    
    func updateDataProfileDetails() {
        updateProfileData = true
    }
    
    func logout() {
        removeAllDataWhileExit = true
    }
    
}
