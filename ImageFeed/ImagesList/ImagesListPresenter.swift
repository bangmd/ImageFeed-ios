import Foundation
import Kingfisher

public protocol ImagesListPresenterProtocol{
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func setupImageListService()
    func setupNotificationObserver()
}

final class ImagesListPresenter: ImagesListPresenterProtocol{
    var view: ImagesListViewControllerProtocol?
    private let imagesListService = ImagesListService.shared
    private var imageListServiceObserver: NSObjectProtocol?
   
    init(view: ImagesListViewControllerProtocol? = nil) {
        self.view = view
    }
    
    func viewDidLoad(){
        setupImageListService()
        view?.updateTableViewAnimated()
        setupNotificationObserver()
    }
    
    func setupImageListService(){
        imagesListService.fetchPhotosNextPage()
    }
    
    func setupNotificationObserver(){
        imageListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                self?.view?.updateTableViewAnimated()
            })
    }
}
