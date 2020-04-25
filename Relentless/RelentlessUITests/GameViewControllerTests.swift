//
//  GameViewControllerTests.swift
//  RelentlessUITests
//
//  Created by Liu Zechu on 4/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest

class GameViewControllerTests: XCTestCase {

    var app: XCUIApplication!

    func setUpWithError() throws {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        XCUIApplication().launch()
    }

    func testGameStartingScreen() throws {
        // swiftlint:disable:next line_length
        app/*@START_MENU_TOKEN@*/.buttons["createRoomButton"]/*[[".buttons[\"button createroom\"]",".buttons[\"createRoomButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        // swiftlint:disable:next line_length
        let button = app/*@START_MENU_TOKEN@*/.buttons["startButton"]/*[[".buttons[\"button start\"]",".buttons[\"startButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        sleep(5)
//        let exists = NSPredicate(format: "exists == 1")
//        expectation(for: exists, evaluatedWith: button, handler: nil)
//        waitForExpectations(timeout: 5, handler: nil)
        button.tap()
        sleep(2)
        let textLabel = app.staticTexts.element(matching: .any, identifier: "Are you ready for the new day?")
        let result = textLabel.exists
        XCTAssertTrue(result)
    }
    
    func testProceedButton() throws {
        // swiftlint:disable:next line_length
        app/*@START_MENU_TOKEN@*/.buttons["createRoomButton"]/*[[".buttons[\"button createroom\"]",".buttons[\"createRoomButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        // swiftlint:disable:next line_length
        let button = app/*@START_MENU_TOKEN@*/.buttons["startButton"]/*[[".buttons[\"button start\"]",".buttons[\"startButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        sleep(5)
        button.tap()
        sleep(2)
        let result = app.buttons["Proceed"].exists
        XCTAssertTrue(result)
    }
    
}
