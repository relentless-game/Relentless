//
//  LobbyViewControllerTests.swift
//  RelentlessUITests
//
//  Created by Liu Zechu on 4/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class LobbyViewControllerTests: XCTestCase {
    
    var app: XCUIApplication!

    func setUpWithError() throws {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        XCUIApplication().launch()
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
