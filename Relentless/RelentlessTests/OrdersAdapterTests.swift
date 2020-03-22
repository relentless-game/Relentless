//
//  OrdersAdapterTests.swift
//  RelentlessTests
//
//  Created by Liu Zechu on 22/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class OrdersAdapterTests: XCTestCase {

    func testEncodeOrdersThenDecodeOrders() {
        let item1 = Book(name: "book1")
        let item2 = Book(name: "book2")
        let item3 = Book(name: "book3")
        let item4 = Book(name: "book4")
        let item5 = Magazine(name: "mag1")
        let item6 = Magazine(name: "mag2")
        let item7 = Magazine(name: "mag3")
        let itemsForOrder1 = [item1, item2, item3]
        let itemsForOrder2 = [item4, item5, item6, item7]
        
        let order1 = Order(items: itemsForOrder1, timeLimitInSeconds: 30)
        let order2 = Order(items: itemsForOrder2, timeLimitInSeconds: 30)
        let orders = [order1, order2]
        
        let encodedString = OrdersAdapter.encodeOrders(orders: orders)!
        let decodedOrders = OrdersAdapter.decodeOrders(from: encodedString)
        
        XCTAssertEqual(decodedOrders, orders)
    }

}
