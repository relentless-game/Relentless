//
//  OrderTests.swift
//  RelentlessTests
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

import XCTest
@testable import Relentless

class OrderTests: XCTestCase {
    let creator = "creator"
    let packageNumber = 1
    let items = [Book(name: "book"), Magazine(name: "magazine")]
    let timeLimit = 1
    let itemsLimit = 5
    var order: Order!
    
    override func setUp() {
        super.setUp()
        order = Order(items: items, timeLimitInSeconds: timeLimit)
    }

    func testInit() {
        let order = Order(items: items, timeLimitInSeconds: timeLimit)
        XCTAssertEqual(order.items, items.sorted())
        XCTAssertEqual(order.timeLimit, timeLimit)
    }

    func testCheckPackage_correctPackage() {
        let package = Package(creator: creator, packageNumber: packageNumber, items: items, itemsLimit: itemsLimit)
        XCTAssertTrue(order.checkPackage(package: package))
    }

    func testCheckPackage_correctPackageInDifferentOrder() {
        var itemsInReversedOrder = items
        itemsInReversedOrder.reverse()
        let package = Package(creator: creator, packageNumber: packageNumber,
                              items: itemsInReversedOrder, itemsLimit: itemsLimit)
        XCTAssertTrue(order.checkPackage(package: package))
    }

    func testCheckPackage_incorrectPackage() {
        var wrongItems = items
        wrongItems.removeFirst()
        let package = Package(creator: creator, packageNumber: packageNumber, items: wrongItems, itemsLimit: itemsLimit)
        XCTAssertFalse(order.checkPackage(package: package))
    }

    func testGetNumberOfDifferences() {
        let packageWithNoItems = Package(creator: creator, packageNumber: packageNumber,
                                         items: [Item](), itemsLimit: itemsLimit)
        XCTAssertEqual(order.getNumberOfDifferences(with: packageWithNoItems), items.count)
    }

    func testEquivalence(other: Order) {
        let copyOfOrder = Order(items: items, timeLimitInSeconds: timeLimit)
        XCTAssertTrue(order == copyOfOrder)
    }

    func testStartOrder() {
        order.startOrder()
        let timeLimit = order.timeLimit
        XCTAssertTrue(order.timeLeft <= timeLimit)
    }
}
