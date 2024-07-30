@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase {
    func testRemoveProfileData(){
        //given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        //when
        presenter.logout()
        //then
        XCTAssertTrue(presenter.removeAllDataWhileExit)
    }
    
    func testUpdateProfileDataAndAvatar(){
        //given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.updateDataAvatar()
        presenter.updateDataProfileDetails()
        
        //then
        XCTAssertTrue(presenter.updateProfileAvatar)
        XCTAssertTrue(presenter.updateProfileData)
    }
}
