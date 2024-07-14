import ImageFeed
import Foundation

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var view: ImageFeed.WebViewViewControllerProtocol?
    var presenter: ImageFeed.WebViewPresenterProtocol?
    var progressViewIsHidden: Bool = false
    var viewDidLoadCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        let shouldHideProgress = abs(newProgressValue - 1.0) <= 0.0001
        (newValue == 1.0) ? (progressViewIsHidden = true) : (progressViewIsHidden = false)
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
    
}
