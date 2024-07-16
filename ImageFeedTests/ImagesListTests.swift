@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase{
    func testDidFetchPhotosNextPageCalled(){
        //given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.setupImageListService()
        
        //then
        XCTAssertTrue(presenter.didFetchPhotosNextPageCalled)
    }    
}
