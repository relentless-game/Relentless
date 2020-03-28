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
    let itemsForFirstOrder = [Book(name: "bookOne"), Book(name: "bookTwo"), Book(name: "bookThree")]
    let itemsForSecondOrder = [Book(name: "bookOne"), Book(name: "bookTwo"), Magazine(name: "magazineOne")]
    let timeLimitForOrderOne = 2
    let timeLimitForOrderTwo = 1

    var orderOne: Order!
    var orderTwo: Order!
    var orders: Set<Order>!
    var house: House!

    override func setUp() {
        super.setUp()
        orderOne = Order(items: itemsForFirstOrder, timeLimitInSeconds: timeLimitForOrderOne)
        orderTwo = Order(items: itemsForSecondOrder, timeLimitInSeconds: timeLimitForOrderTwo)
        orders = Set<Order>([orderOne, orderTwo])
        house = House(orders: Set<Order>(orders))
        orderOne.startOrder()
        orderTwo.startOrder()
    }

    func testInit() {
        let house = House(orders: orders)
        XCTAssertEqual(house.orders, orders)
    }

    func testCheckPackage_correctPackage() {
        let package = Package(creator: creator, packageNumber: packageNumber, items: itemsForFirstOrder)
        XCTAssertTrue(house.checkPackage(package: package))
    }

    func testCheckPackage_incorrectPackage() {
        let package = Package(creator: creator, packageNumber: packageNumber, items: [Item]())
        XCTAssertFalse(house.checkPackage(package: package))
    }

    func testGetClosestOrder_varyingDifferences() {
        var itemsForFirstOrderMissingFirstOne = itemsForFirstOrder
        itemsForFirstOrderMissingFirstOne.removeFirst()
        let package = Package(creator: creator, packageNumber: packageNumber, items: itemsForFirstOrderMissingFirstOne)
        guard let order = house.getClosestOrder(for: package) else {
            XCTFail("Should not be nil")
            return
        }
        XCTAssertEqual(order, orderOne)
    }

    func testGetClosestOrder_sameDifferences() {
        var itemsForFirstOrderMissingLastOne = itemsForFirstOrder
        itemsForFirstOrderMissingLastOne.removeLast()
        let package = Package(creator: creator, packageNumber: packageNumber, items: itemsForFirstOrderMissingLastOne)
        guard let order = house.getClosestOrder(for: package) else {
            XCTFail("Should not be nil")
            return
        }
        XCTAssertEqual(order, orderTwo)
    }
}
