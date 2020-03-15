//
//  GameManager.swift
//  RelentlessTests
//
//  Created by Chow Yi Yin on 15/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class GameManager: XCTestCase {
    let gameId = 1
    let userId = "userId"
    let userName = "username"
    let profileImage = UIImage(
    var gameManager: GameManager!

    override func setUp() {
        let user = Player(userId: userId, userName: userName, profileImage: profileImage)
        gameManager = GameManager(
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
