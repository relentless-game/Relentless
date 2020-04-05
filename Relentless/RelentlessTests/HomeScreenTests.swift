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

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateGameButtonExists() throws {
        app.launch()
        XCTAssertTrue(app.buttons["Create Game"].exists)
    }
    
    func testJoinGameButtonExists() throws {
        app.launch()
        XCTAssertTrue(app.buttons["Join Game"].exists)
    }

}
