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
        let item1 = TitledItem(name: "1", category: Category(name: "book"),
                               isInventoryItem: true, isOrderItem: true,
                               imageString: "placeholder")
        let item2 = TitledItem(name: "2", category: Category(name: "book"),
                               isInventoryItem: true, isOrderItem: true,
                               imageString: "placeholder")
        let item3 = TitledItem(name: "3", category: Category(name: "book"),
                               isInventoryItem: true, isOrderItem: true,
                               imageString: "placeholder")
        let item4 = StatefulItem(category: Category(name: "wheel"), stateIdentifier: 1,
                                 isInventoryItem: true, isOrderItem: false,
                                 imageString: "placeholder")
        let item5 = StatefulItem(category: Category(name: "wheel"), stateIdentifier: 2,
                                 isInventoryItem: true, isOrderItem: false,
                                 imageString: "placeholder")
        
        let itemsForOrder1 = [item1, item2, item3]
        let itemsForOrder2 = [item4, item5]
        
        let order1 = Order(items: itemsForOrder1, timeLimitInSeconds: 30)
        let order2 = Order(items: itemsForOrder2, timeLimitInSeconds: 100)
        let orders = [order1, order2]
        
        let encodedString = OrdersAdapter.encodeOrders(orders: orders)!
        let decodedOrders = OrdersAdapter.decodeOrders(from: encodedString)
         
        XCTAssertEqual(decodedOrders, orders)
    }

}
