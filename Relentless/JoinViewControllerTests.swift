//
//  JoinViewControllerTests.swift
//  RelentlessUITests
//
//  Created by Liu Zechu on 4/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest

class JoinViewControllerTests: XCTestCase {

    var app: XCUIApplication!

    private let joinGameString = "Join Game"
    private let createGameString = "Create Game"
    private let joinString = "Join"
    private let backString = "Back"
    private let testTeamCode = "4318"
    
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
        app.buttons[joinGameString].tap()
        XCTAssertTrue(app.buttons[backString].exists)
    }
    
    func testBackButtonReturnsBackToHome() throws {
        app.launch()
        app.buttons[joinGameString].tap()
        app.buttons[backString].tap()
        let result = app.buttons[createGameString].exists
        XCTAssertTrue(result)
    }
    
    func testTeamCodeLabelExists() throws {
        app.launch()
        app.buttons[joinGameString].tap()
        let result = app.staticTexts.element(matching: .any, identifier: "Team Code").exists
        XCTAssertTrue(result)
    }

    func testJoinButtonExists() throws {
        app.launch()
        app.buttons[joinGameString].tap()
        let result = app.buttons[joinString].exists
        XCTAssertTrue(result)
    }
    
    func testTextFieldExists() throws {
        app.launch()
        app.buttons[joinGameString].tap()
        let result = app.textFields["teamCodeTextField"].exists
        XCTAssertTrue(result)
    }
    
    func testInvalidCodePopUp() throws {
        app.launch()
        app.buttons[joinGameString].tap()
        let textfield = app.textFields["teamCodeTextField"]
        textfield.tap()
        textfield.typeText("1234")
        app.buttons[joinString].tap()
        let alertString = "The team code is invalid. Are you sure you keyed in the right code?"
        let result = app.alerts.element.staticTexts[alertString].exists
        XCTAssertTrue(result)
    }
    
    func testValidGameCode_seguesToLobby() throws {
        app.launch()
        app.buttons[joinGameString].tap()
        let textfield = app.textFields["teamCodeTextField"]
        textfield.tap()
        textfield.typeText(testTeamCode)
        app.buttons[joinString].tap()
        
        // check whether it's in lobby view
        let result = app.staticTexts["Team Code"].exists
        XCTAssertTrue(result)
    }
    
}
