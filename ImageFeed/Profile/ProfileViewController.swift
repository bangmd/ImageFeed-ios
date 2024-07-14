import UIKit

public protocol ProfileViewControllerProtocol: AnyObject{
    var presenter: ProfileViewPresenterProtocol? { get set }
    func showAvatar(url: URL)
    func updateProfileDetails(name: String, loginName: String, bio: String)
    func resetProfileView()
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol{
    var presenter: ProfileViewPresenterProtocol?
    var userNameLabel = UILabel()
    var loginNameLabel = UILabel()
    var textLabel = UILabel()
    var iconImageView = UIImageView()
    private var profileImageServiceObserver: NSObjectProtocol?
    var animationLayers = Set<CALayer>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        addUserNameLabel()
        addIconImageView()
        addLoginNameLabel()
        addTextLabel()
        addLogoutButton()
        
        presenter = ProfileViewPresenter(view: self)
        presenter?.viewDidLoad()
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ){ [weak self] _ in
                self?.presenter?.updateDataAvatar()
            }
        presenter?.updateDataProfileDetails()
    }
    
    
    func showAvatar(url: URL){
        iconImageView.kf.indicatorType = .activity
        iconImageView.kf.setImage(with: url, placeholder: UIImage(named: "personImage"))
    }
    
    func updateProfileDetails(name: String, loginName: String, bio: String){
        self.userNameLabel.text = name
        self.loginNameLabel.text = loginName
        self.textLabel.text = bio
        presenter?.updateDataAvatar()
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
        logoutButton.accessibilityIdentifier = "LogoutButton"
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
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены что хотите выйти?", preferredStyle: .alert)
        
        let yesButtonAction = UIAlertAction(title: "Да", style: .default) { _ in
            self.presenter?.logout()
        }
        
        let noButtonAction = UIAlertAction(title: "Нет", style: .default, handler: nil)
        
        alert.addAction(yesButtonAction)
        alert.addAction(noButtonAction)
    
        present(alert, animated: true, completion: nil)
    }
    
    func resetProfileView() {
        self.userNameLabel.text = "Username"
        self.loginNameLabel.text = "@username"
        self.textLabel.text = "Some Text"
        self.iconImageView.image = UIImage(named: "personImage")
    }
}
