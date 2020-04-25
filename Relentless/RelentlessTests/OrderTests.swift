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
    let imageRepresentation = ImageRepresentation(imageStrings: ["placeholder"])
    var item1: TitledItem!
    var item2: TitledItem!
    var item3: TitledItem!
    var item4: StatefulItem!
    var item5: StatefulItem!
    
    var items: [Item] = []
    let timeLimit = 1
    let itemsLimit = 5
    var order: Order!
    
    override func setUp() {
        super.setUp()
        item1 = TitledItem(name: "1", category: Category(name: "book"),
                           isInventoryItem: true, isOrderItem: true,
                           imageRepresentation: imageRepresentation)
        item2 = TitledItem(name: "2", category: Category(name: "book"),
                           isInventoryItem: true, isOrderItem: true,
                           imageRepresentation: imageRepresentation)
        item3 = TitledItem(name: "3", category: Category(name: "book"),
                           isInventoryItem: true, isOrderItem: true,
                           imageRepresentation: imageRepresentation)
        item4 = StatefulItem(category: Category(name: "wheel"), stateIdentifier: 1,
                             isInventoryItem: true, isOrderItem: false,
                             imageRepresentation: imageRepresentation)
        item5 = StatefulItem(category: Category(name: "wheel"), stateIdentifier: 2,
                             isInventoryItem: true, isOrderItem: false,
                             imageRepresentation: imageRepresentation)
        items = [item1, item2, item3, item4, item5]
        order = Order(items: items, timeLimitInSeconds: timeLimit)
    }

    func testInit() {
        let order = Order(items: items, timeLimitInSeconds: timeLimit)
        
        XCTAssertEqual(order.items, items.sorted())
        XCTAssertEqual(order.timeLimit, timeLimit)
    }

    func testCheckPackage_correctPackage() {
        let package = Package(creator: creator, creatorAvatar: .blue,
                              packageNumber: packageNumber, items: items, itemsLimit: itemsLimit)
        XCTAssertTrue(order.checkPackage(package: package))
    }

    func testCheckPackage_correctPackageInDifferentOrder() {
        var itemsInReversedOrder = items
        itemsInReversedOrder.reverse()
        let package = Package(creator: creator, creatorAvatar: .blue,
                              packageNumber: packageNumber,
                              items: itemsInReversedOrder, itemsLimit: itemsLimit)
        XCTAssertTrue(order.checkPackage(package: package))
    }

    func testCheckPackage_incorrectPackage() {
        var wrongItems = items
        wrongItems.removeFirst()
        let package = Package(creator: creator, creatorAvatar: .blue,
                              packageNumber: packageNumber, items: wrongItems, itemsLimit: itemsLimit)
        XCTAssertFalse(order.checkPackage(package: package))
    }

    func testGetNumberOfDifferences_emptyPackage() {
        let packageWithNoItems = Package(creator: creator, creatorAvatar: .blue,
                                         packageNumber: packageNumber,
                                         items: [Item](), itemsLimit: itemsLimit)
        XCTAssertEqual(order.getNumberOfDifferences(with: packageWithNoItems), items.count)
    }

    func testGetNumberOfDifferences_fewerItems() {
        guard let item1 = item1, let item2 = item2, let item3 = item3 else {
            XCTFail("Test set up went wrong... items should not be nil")
            return
        }
        let packageItems = [item1, item2, item3]
        let packageWithFewerItems = Package(creator: creator, creatorAvatar: .blue,
                                            packageNumber: packageNumber,
                                            items: packageItems, itemsLimit: itemsLimit)
        XCTAssertEqual(order.getNumberOfDifferences(with: packageWithFewerItems),
                       items.count - packageItems.count)
    }

    func testGetNumberOfDifferences_moreItems() {
        guard let item1 = item1, let item2 = item2, let item3 = item3, let item4 = item4,
            let item5 = item5 else {
            XCTFail("Test set up went wrong... items should not be nil")
            return
        }
        let packageItems = [item1, item2, item3, item4, item5, item1]
        let packageWithMoreItems = Package(creator: creator, creatorAvatar: .blue,
                                           packageNumber: packageNumber,
                                           items: packageItems, itemsLimit: itemsLimit)
        XCTAssertEqual(order.getNumberOfDifferences(with: packageWithMoreItems),
                       packageItems.count - items.count)
    }

    func testEquivalence(other: Order) {
        let copyOfOrder = Order(items: items, timeLimitInSeconds: timeLimit)
        XCTAssertTrue(order == copyOfOrder)
    }

    func testStartOrder() {
        order.startOrder()
        let timeLimit = order.timeLimit
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
            XCTAssertTrue(self.order.timeLeft < timeLimit)
        })
    }
}
