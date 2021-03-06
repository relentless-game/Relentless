//
//  HomeScreenTests.swift
//  RelentlessUITests
//
//  Created by Liu Zechu on 4/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest

class HomeScreenTests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        XCUIApplication().launch()
    }

    func testCreateGameButtonExists() throws {
        app.launch()
        let result = app.buttons.element(matching: .button,
                                         identifier: "createRoomButton").exists
        XCTAssertTrue(result)
    }
    
    func testJoinGameButtonExists() throws {
        app.launch()
        let result = app.buttons.element(matching: .button,
                                         identifier: "joinRoomButton").exists
        XCTAssertTrue(result)
    }

}
