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

    private let joinRoomIdentifier = "joinRoomButton"
    private let createRoomIdentifier = "createRoomButton"
    private let joinIdentifier = "joinButton"
    private let backIdentifier = "backButton"
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
        app.buttons.element(matching: .button, identifier: joinRoomIdentifier).tap()
        let result = app.buttons.element(matching: .button,
                                         identifier: backIdentifier).exists
        XCTAssertTrue(result)
    }
    
    func testBackButtonReturnsBackToHome() throws {
        app.launch()
        app.buttons.element(matching: .button, identifier: joinRoomIdentifier).tap()
        app.buttons.element(matching: .button, identifier: backIdentifier).tap()
        let result = app.buttons.element(matching: .button,
                                         identifier: createRoomIdentifier).exists
        XCTAssertTrue(result)
    }
    
    func testTeamCodeLabelExists() throws {
        app.launch()
        app.buttons.element(matching: .button, identifier: joinRoomIdentifier).tap()
        let result = app.staticTexts.element(matching: .any, identifier: "Team Code").exists
        XCTAssertTrue(result)
    }

    func testJoinButtonExists() throws {
        app.launch()
        app.buttons.element(matching: .button, identifier: joinRoomIdentifier).tap()
        let result = app.buttons.element(matching: .button, identifier: joinIdentifier).exists
        XCTAssertTrue(result)
    }
    
    func testTextFieldExists() throws {
        app.launch()
        app.buttons.element(matching: .button, identifier: joinRoomIdentifier).tap()
        let result = app.textFields["teamCodeTextField"].exists
        XCTAssertTrue(result)
    }
    
    func testInvalidCodePopUp() throws {
        app.launch()
        // swiftlint:disable:next line_length
        app/*@START_MENU_TOKEN@*/.buttons["joinRoomButton"]/*[[".buttons[\"button joinroom\"]",".buttons[\"joinRoomButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.textFields["teamCodeTextField"].tap()
        app.typeText("1234")
        // swiftlint:disable:next line_length
        app/*@START_MENU_TOKEN@*/.buttons["joinButton"]/*[[".buttons[\"button joinroom\"]",".buttons[\"joinButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        sleep(3)
        let text = "The team code is invalid. Are you sure you keyed in the right code?"
        let result = app.staticTexts.element(matching: .any, identifier: text).exists
        XCTAssertTrue(result)
    }
    
    func testValidGameCode_seguesToLobby() throws {
        app.launch()
        app.buttons.element(matching: .button, identifier: joinRoomIdentifier).tap()
        let textfield = app.textFields["teamCodeTextField"]
        textfield.tap()
        textfield.typeText(testTeamCode)
        app.buttons.element(matching: .button, identifier: joinIdentifier).tap()

        // check whether it's in lobby view
        let result = app.staticTexts["Team Code"].exists
        XCTAssertTrue(result)
    }
    
    func testBackButton() throws {
        app.launch()
        // swiftlint:disable:next line_length
        app/*@START_MENU_TOKEN@*/.buttons["joinRoomButton"]/*[[".buttons[\"button joinroom\"]",".buttons[\"joinRoomButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.textFields["teamCodeTextField"].tap()
        // swiftlint:disable:next line_length
        app/*@START_MENU_TOKEN@*/.buttons["joinButton"]/*[[".buttons[\"button joinroom\"]",".buttons[\"joinButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        // swiftlint:disable:next line_length
        app/*@START_MENU_TOKEN@*/.buttons["backButton"]/*[[".buttons[\"button back\"]",".buttons[\"backButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let result = app.buttons.element(matching: .button,
                                         identifier: "createRoomButton").exists
        XCTAssertTrue(result)
    }
}
