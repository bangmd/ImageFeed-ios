import UIKit

protocol AuthViewControllerDelegate: AnyObject{
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController{
    @IBOutlet var authButton: UIButton!
    private let authImage = UIImageView()
    private let showWebViewSegueIdentifier = "ShowWebView"
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        addImage()
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier{
            guard 
                let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(showWebViewSegueIdentifier)") }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    private func addImage(){
        authImage.image = UIImage(named: "auth_screen_logo")
        
        view.addSubview(authImage)
        authImage.translatesAutoresizingMaskIntoConstraints = false
        authImage.widthAnchor.constraint(equalToConstant: 60).isActive = true
        authImage.heightAnchor.constraint(equalToConstant: 60).isActive = true
        authImage.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        authImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "Backward") // 1
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "Backward") // 2
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil) // 3
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP-Black") // 4
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

