import UIKit
import ProgressHUD

final class SplashViewController: UIViewController, UINavigationControllerDelegate{
    private let storage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let showAuthViewSegueIdentifier = "showAuthScreen"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if storage.token == nil{
            performSegue(withIdentifier: showAuthViewSegueIdentifier, sender: nil)
        }else{
            switchToTabBarController()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthViewSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthViewSegueIdentifier)")
                return
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
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
            switch result{
            case .success:
                guard let token = self.storage.token else { return }
                self.fetchProfile(token)
            case .failure:
                break
            }
        }
        
    }
    
    private func fetchProfile(_ token: String){
        guard let token = self.storage.token else { return }
        profileService.fetchProfile(token) { result in
            switch result{
            case .success:
                print("success with getting data")
                self.switchToTabBarController()
            case .failure(_):
                print("failed get data")
            }
        }
        
    }
}


