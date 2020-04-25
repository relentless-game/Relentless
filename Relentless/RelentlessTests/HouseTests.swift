//
//  HouseTests.swift
//  RelentlessTests
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class HouseTests: XCTestCase {
    let creator = "creator"
    let packageNumber = 1
    let imageRepresentation = ImageRepresentation(imageStrings: ["placeholder"])

    var item1: TitledItem!
    var item2: TitledItem!
    var item3: TitledItem!
    var item4: StatefulItem!
    var item5: StatefulItem!

    var itemsForFirstOrder: [Item] = []
    var itemsForSecondOrder: [Item] = []
    let timeLimitForOrderOne = 2
    let timeLimitForOrderTwo = 1
    let satisfactionFactor: Double = 0.1
    let itemsLimit = 5

    var orderOne: Order!
    var orderTwo: Order!
    var orders: Set<Order>!
    var house: House!

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
        itemsForFirstOrder = [item1, item2, item3]
        itemsForSecondOrder = [item4, item5]
        
        orderOne = Order(items: itemsForFirstOrder, timeLimitInSeconds: timeLimitForOrderOne)
        orderTwo = Order(items: itemsForSecondOrder, timeLimitInSeconds: timeLimitForOrderTwo)
        orders = Set<Order>([orderOne, orderTwo])
        house = House(orders: Set<Order>(orders), satisfactionFactor: satisfactionFactor)
        orderOne.startOrder()
        orderTwo.startOrder()
    }

    func testInit() {
        let house = House(orders: orders, satisfactionFactor: satisfactionFactor)
        XCTAssertEqual(house.orders, orders)
    }

    func testCheckPackage_correctPackage() {
        let package = Package(creator: creator, creatorAvatar: .blue, packageNumber: packageNumber,
                              items: itemsForFirstOrder, itemsLimit: itemsLimit)
        XCTAssertTrue(house.checkPackage(package: package))
    }

    func testCheckPackage_incorrectPackage() {
        let package = Package(creator: creator, creatorAvatar: .blue,
                              packageNumber: packageNumber, items: [Item](), itemsLimit: itemsLimit)
        XCTAssertFalse(house.checkPackage(package: package))
    }

    func testGetClosestOrder_varyingDifferences() {
        var itemsForFirstOrderMissingFirstOne = itemsForFirstOrder
        itemsForFirstOrderMissingFirstOne.removeFirst()
        let package = Package(creator: creator, creatorAvatar: .blue,
                              packageNumber: packageNumber,
                              items: itemsForFirstOrderMissingFirstOne, itemsLimit: itemsLimit)
        guard let order = house.getClosestOrder(for: package) else {
            XCTFail("Should not be nil")
            return
        }
        XCTAssertEqual(order, orderOne)
    }

    func testGetClosestOrder_sameDifferences() {
        var itemsForFirstOrderMissingLastOne = itemsForFirstOrder
        itemsForFirstOrderMissingLastOne.removeLast()
        let package = Package(creator: creator, creatorAvatar: .blue,
                              packageNumber: packageNumber,
                              items: itemsForFirstOrderMissingLastOne, itemsLimit: itemsLimit)
        guard let order = house.getClosestOrder(for: package) else {
            XCTFail("Should not be nil")
            return
        }
        XCTAssertEqual(order, orderOne)
    }
}
