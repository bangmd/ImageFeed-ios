import UIKit
import ProgressHUD

final class SplashViewController: UIViewController, UINavigationControllerDelegate{
    private let storage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let showAuthViewSegueIdentifier = "showAuthScreen"
    private var imageView = UIImageView()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if storage.token == nil{
            showAuthScreen()
        }else{
            loadDataToProfile()
            switchToTabBarController()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViewItems()
    }
    
    private func showAuthScreen(){
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController")
        guard let viewController = viewController as? AuthViewController else { return }
        viewController.delegate = self
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
    
    private func addViewItems(){
        view.backgroundColor = .ypBlack
        let image = UIImage(named: "Vector")
        imageView = UIImageView(image: image)
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
   
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == showAuthViewSegueIdentifier {
//            guard
//                let navigationController = segue.destination as? UINavigationController,
//                let viewController = navigationController.viewControllers[0] as? AuthViewController
//            else {
//                assertionFailure("Failed to prepare for \(showAuthViewSegueIdentifier)")
//                return
//            }
//            viewController.delegate = self
//        } else {
//            super.prepare(for: segue, sender: sender)
//        }
//    }
    
    private func switchToTabBarController(){
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true){ [weak self] in
            self?.fetchOAuthToken(code)
            UIBlockingProgressHUD.dismiss()
            
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        OAuth2Service().fetchOAuthTokenResponseBody(with: code) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result{
                case .success:
                    self.loadDataToProfile()
                case .failure:
                    self.showErrorLoginAlert()
                    ProgressHUD.dismiss()
                }
            }
        }
    }
    
    private func showErrorLoginAlert(){
        DispatchQueue.main.async{
            let alert = UIAlertController(
                title: "Что-то пошло не так(",
                message: "Не удалось войти в систему",
                preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    private func loadDataToProfile(){
        guard let token = self.storage.token else { return }
        fetchProfile(token)
    }
    
    private func fetchProfile(_ token: String){
        guard let token = storage.token else { return }
        profileService.fetchProfile(token) { result in
            switch result{
            case .success:
                self.fetchProfileImage(token)
                self.switchToTabBarController()
                print("success with getting data")
            case .failure(_):
                print("failed get data")
            }
        }
    }
    
    private func fetchProfileImage(_ token: String){
        guard let token = storage.token else { return }
        profileImageService.fetchProfileImageURL(token) { result in
            switch result{
            case .success(let photoLink):
                print("Photo Link \(photoLink)")
            case .failure(_):
                print("failed get image link")
            }
        }
    }
    
}


