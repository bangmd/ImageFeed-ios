import UIKit
import WebKit
import Kingfisher

public protocol ProfileViewPresenterProtocol{
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func updateDataAvatar()
    func updateDataProfileDetails()
    func logout()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol{
    weak var view: ProfileViewControllerProtocol?
    private let profileImage = ProfileImageService.shared
    private let profileService = ProfileService.shared
    private let storage = OAuth2TokenStorage()
    
    init(view: ProfileViewControllerProtocol? = nil) {
        self.view = view
    }
    
    func viewDidLoad(){
        updateDataProfileDetails()
    }
    
    func updateDataAvatar(){
        guard
            let profileImageURL = profileImage.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        view?.showAvatar(url: url)
    }
    
    func updateDataProfileDetails(){
        guard let profile = profileService.profile else { return }
        view?.updateProfileDetails(name: profile.name, loginName: profile.loginName, bio: profile.bio)
    }
    
    func logout(){
        cleanCookies()
        resetToken()
        view?.resetProfileView()
        resetPhotos()
        switchToSplashVC()
    }
    
    private func switchToSplashVC() {
        guard let window = UIApplication.shared.windows.first else { preconditionFailure("Invalid Configuration") }
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
    }
    
    private func resetToken() {
        guard storage.removeToken() else {
            assertionFailure("Can't remove token")
            return
        }
    }
    
    private func resetPhotos() {
        ImagesListService.shared.resetPhotos()
    }
    
    private func cleanCookies(){
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
}
