//
//  PackingViewControllerTests.swift
//  RelentlessUITests
//
//  Created by Liu Zechu on 4/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest

class PackingViewControllerTests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        XCUIApplication().launch()
        
        // Get to the packing screen
        // swiftlint:disable:next line_length
        app/*@START_MENU_TOKEN@*/.buttons["createRoomButton"]/*[[".buttons[\"button createroom\"]",".buttons[\"createRoomButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        // swiftlint:disable:next line_length
        let button = app/*@START_MENU_TOKEN@*/.buttons["startButton"]/*[[".buttons[\"button start\"]",".buttons[\"startButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        sleep(5)
        button.tap()
        sleep(2)
        app.buttons["Proceed"].tap()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testToHousesButton() throws {
//        app.collectionViews.containing(.image, identifier:"package_site").element.tap()
        // swiftlint:disable:next line_length
//        app/*@START_MENU_TOKEN@*/.staticTexts["To Packing"]/*[[".buttons[\"To Packing\"].staticTexts[\"To Packing\"]",".staticTexts[\"To Packing\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        app.collectionViews.cells.otherElements.containing(.image, identifier:"add_blue").element.tap()
        let result = app.collectionViews.containing(.image, identifier: "package_site").element.exists
        XCTAssertTrue(result)
    }
    
    func textAddPackageButton() throws {
        let result = app.collectionViews.cells
            .otherElements.containing(.image, identifier: "add_blue").element.exists
        XCTAssertTrue(result)
    }
    
}
