//
//  GameManager.swift
//  RelentlessTests
//
//  Created by Chow Yi Yin on 15/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class GameManagerTests: XCTestCase {
    let gameId = 1
    let userId = "userId"
    let userName = "username"
    let profileImage = UIImage()
    let package1 = Package(creator: "user", packageNumber: 1, items: [])
    let package2 = Package(creator: "creator", packageNumber: 2, items: [])
    var gameManager: GameManager!

    override func setUp() {
        super.setUp()
        let player = Player(userId: userId, userName: userName, profileImage: profileImage)
        gameManager = GameManager(gameId: gameId, player: player)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

//    func testAddPackage_onePackage() {
//        gameManager.addPackage(package: package1)
//        XCTAssertEqual(gameManager.packages.count, 1)
//        let package = gameManager.packages[0]
//        XCTAssertEqual(gameManager.currentlyOpenPackage, package)
//    }
//
//    func test_AddPackage_twoPackages_packageNumber() {
//        gameManager.addPackage(package: package1)
//        gameManager.addPackage(package: package2)
//        XCTAssertEqual(gameManager.packages.count, 2)
//        let firstPackage = gameManager.packages[0]
//        let secondPackage = gameManager.packages[1]
//        XCTAssertTrue(firstPackage.packageNumber < secondPackage.packageNumber)
//        XCTAssertEqual(gameManager.currentlyOpenPackage, secondPackage)
//    }

    func testRemovePackage_packageExists() {
        gameManager.addPackage(package: package1)
        let existingPackage = gameManager.packages[0]
        gameManager.removePackage(package: existingPackage)
        XCTAssertTrue(gameManager.packages.isEmpty)
    }

    func testRemovePackage_packageDoesNotExist() {
        gameManager.addPackage(package: package1)
        let package = Package(creator: "creator", packageNumber: 2, items: [Item]())
        gameManager.removePackage(package: package)
        XCTAssertEqual(gameManager.packages.count, 1)
    }

}
