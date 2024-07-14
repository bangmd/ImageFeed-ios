import ImageFeed
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol{
    var view: ImageFeed.ImagesListViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var didFetchPhotosNextPageCalled: Bool = false
    
    func viewDidLoad() {
        
    }
    
    func setupImageListService() {
        didFetchPhotosNextPageCalled = true
    }
    
    func setupNotificationObserver() {
        
    }
    
    
}
