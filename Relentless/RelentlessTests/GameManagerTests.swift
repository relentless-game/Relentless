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
    let profileImage = PlayerAvatar.red
    let package1 = Package(creator: "user", creatorAvatar: .blue, packageNumber: 1, items: [], itemsLimit: 5)
    let package2 = Package(creator: "creator", creatorAvatar: .blue, packageNumber: 2, items: [], itemsLimit: 5)
    var gameManager: GameManager!

    override func setUp() {
        super.setUp()
        let player = Player(userId: userId, userName: userName, profileImage: profileImage)
        gameManager = GameManager(gameId: gameId, player: player)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testAddNewPackage_onePackage() {
        gameManager.addNewPackage()
        XCTAssertEqual(gameManager.packages.count, 1)
    }

    func testAddNewPackage_twoPackages() {
        gameManager.addNewPackage()
        gameManager.addNewPackage()
        XCTAssertEqual(gameManager.packages.count, 2)
        let firstPackage = gameManager.packages[0]
        let secondPackage = gameManager.packages[1]
        XCTAssertTrue(firstPackage.packageNumber < secondPackage.packageNumber)
        XCTAssertEqual(gameManager.currentlyOpenPackage, secondPackage)
    }

    func testAddPackage_onePackage() {
        gameManager.addPackage(package: package1)
        XCTAssertEqual(gameManager.packages.count, 1)
    }

    func test_AddPackage_twoPackages_packageNumber() {
        gameManager.addPackage(package: package1)
        gameManager.addPackage(package: package2)
        XCTAssertEqual(gameManager.packages.count, 2)
    }

    func testRemovePackage_packageExists() {
        gameManager.addPackage(package: package1)
        let existingPackage = gameManager.packages[0]
        gameManager.removePackage(package: existingPackage)
        XCTAssertTrue(gameManager.packages.isEmpty)
    }

    func testRemovePackage_packageDoesNotExist() {
        gameManager.addPackage(package: package1)
        let package = Package(creator: "creator", creatorAvatar: .blue,
                              packageNumber: 2, items: [Item](), itemsLimit: 5)
        gameManager.removePackage(package: package)
        XCTAssertEqual(gameManager.packages.count, 1)
    }

    func testOpenPackage() {
        gameManager.addPackage(package: package1)
        gameManager.openPackage(package: package1)
        XCTAssertEqual(gameManager.currentlyOpenPackage, package1)
    }

    func testRemovePackage_whenPackageOpen() {
        gameManager.addPackage(package: package1)
        gameManager.openPackage(package: package1)
        gameManager.removePackage(package: package1)
        XCTAssertNil(gameManager.currentlyOpenPackage)
    }

}
