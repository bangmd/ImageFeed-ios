import UIKit

final class ProfileViewController: UIViewController{
    var userNameLabel = UILabel()
    var loginNameLabel = UILabel()
    var textLabel = UILabel()
    private let profileService = ProfileService.shared
    private let storage = OAuth2TokenStorage()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        addUserNameLabel()
        addIconImageView()
        addLoginNameLabel()
        addTextLabel()
        addLogoutButton()
        
        updateProfileDetails()
        print(userNameLabel.text)
        print(profileService.profile?.loginName)
    }
    
    func updateProfileDetails(){
        guard let profile = profileService.profile else { return }
        self.userNameLabel.text = profile.username
        self.loginNameLabel.text = profile.loginName
        self.textLabel.text = profile.bio
    }
    
    func addUserNameLabel(){
        view.addSubview(userNameLabel)
        userNameLabel.text = "Екатерина Смирнова"
        userNameLabel.font = .boldSystemFont(ofSize: 23)
        userNameLabel.textColor = .ypWhite
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 110).isActive = true
        userNameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
    }
    
    func addIconImageView(){
        let image = UIImage(named: "iconPhoto")
        let iconImageView: UIImageView = UIImageView(image: image)
        view.addSubview(iconImageView)
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
        print("I'm just button")
    }
    
}

