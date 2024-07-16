import XCTest
@testable import ImageFeed

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        let doneButton = app.toolbars.buttons["Done"]
        loginTextField.tap()
        loginTextField.typeText("mail@gmail.com")
        doneButton.tap()
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        passwordTextField.typeText("password")
        doneButton.tap()
        webView.waitForExistence(timeout: 5)
        webView.buttons["Login"].tap()
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        sleep(10)
        let firstCell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        let secondCell = tablesQuery.children(matching: .cell).element(boundBy: 1)
        firstCell.swipeUp()
        sleep(10)
        secondCell.buttons["LikeButton"].tap()
        secondCell.buttons["LikeButton"].tap()
        sleep(5)
        secondCell.tap()
        sleep(2)
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.exists, "Изображение не существует")
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        let backButton = app.buttons["BackButton"]
        XCTAssertTrue(backButton.exists, "Кнопка 'BackButton' не существует")
        backButton.tap()
    }
    
    
    func testProfile() throws {
        let profileView = app.tabBars.buttons.element(boundBy: 1)
        profileView.tap()
        XCTAssert(app.staticTexts["Username"].exists)
        XCTAssert(app.staticTexts["@username"].exists)
        let logout = app.buttons["LogoutButton"]
        logout.tap()
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
