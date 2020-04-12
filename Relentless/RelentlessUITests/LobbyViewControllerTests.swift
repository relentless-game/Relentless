//
//  LobbyViewControllerTests.swift
//  RelentlessUITests
//
//  Created by Liu Zechu on 4/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest

class LobbyViewControllerTests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        XCUIApplication().launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBackButtonExists() throws {
        app.launch()
        app.buttons["createRoomButton"].tap()
        XCTAssertTrue(app.buttons["backButton"].exists)
    }

    func testStartButtonExists() throws {
        app.launch()
        app.buttons["createRoomButton"].tap()
        XCTAssertTrue(app.buttons["startButton"].exists)
    }
    
}
