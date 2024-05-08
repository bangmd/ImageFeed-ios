import UIKit
import WebKit
import Kingfisher

final class ProfileViewController: UIViewController{
    var userNameLabel = UILabel()
    var loginNameLabel = UILabel()
    var textLabel = UILabel()
    var iconImageView = UIImageView()
    private let profileService = ProfileService.shared
    private let storage = OAuth2TokenStorage()
    private let profileImage = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ){ [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
        
        view.backgroundColor = .ypBlack
        addUserNameLabel()
        addIconImageView()
        addLoginNameLabel()
        addTextLabel()
        addLogoutButton()
        updateProfileDetails()
    }
    
    private func updateAvatar(){
        guard
            let profileImageURL = profileImage.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        iconImageView.kf.indicatorType = .activity
        iconImageView.kf.setImage(with: url, placeholder: UIImage(named: "personImage"))
    }
    
    func updateProfileDetails(){
        guard let profile = profileService.profile else { return }
        self.userNameLabel.text = profile.name
        self.loginNameLabel.text = profile.loginName
        self.textLabel.text = profile.bio
        updateAvatar()
    }
    
    func addUserNameLabel(){
        view.addSubview(userNameLabel)
        userNameLabel.text = "Username"
        userNameLabel.font = .boldSystemFont(ofSize: 23)
        userNameLabel.textColor = .ypWhite
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 110).isActive = true
        userNameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
    }
    
    func addIconImageView(){
        let image = UIImage(named: "personImage")
        iconImageView = UIImageView(image: image)
        view.addSubview(iconImageView)
        iconImageView.layer.cornerRadius = 35
        iconImageView.clipsToBounds = true
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant:70),
            iconImageView.heightAnchor.constraint(equalToConstant: 70),
            iconImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            iconImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    func addLoginNameLabel(){
        loginNameLabel.text = "@username"
        loginNameLabel.font = .systemFont(ofSize: 13)
        loginNameLabel.textColor = .ypGray
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        
        NSLayoutConstraint.activate([
            loginNameLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    func addTextLabel(){
        textLabel.text = "Some text"
        textLabel.font = .systemFont(ofSize: 13)
        textLabel.textColor = .ypWhite
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    func addLogoutButton(){
        let logoutButton = UIButton.systemButton(with: UIImage(systemName: "ipad.and.arrow.forward")!,
                                                 target: self,
                                                 action: #selector(Self.didTapButton))
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.tintColor = .ypRed
        view.addSubview(logoutButton)
        
        
        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 55),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            logoutButton.widthAnchor.constraint(equalToConstant: 24),
            logoutButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    @objc
    private func didTapButton(){
        logout()
    }
    
}

private extension ProfileViewController{
    func logout(){
        cleanCookies()
        resetToken()
        resetProfileView()
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
    
    private func resetProfileView() {
        self.userNameLabel.text = "Username"
        self.loginNameLabel.text = "@username"
        self.textLabel.text = "Some Text"
        self.iconImageView.image = UIImage(named: "personImage")
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
