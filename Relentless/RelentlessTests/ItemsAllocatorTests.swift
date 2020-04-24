//
//  ItemsAllocatorTests.swift
//  RelentlessTests
//
//  Created by Chow Yi Yin on 20/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class ItemsAllocatorTests: XCTestCase {

    func testAllocation_allItemsAllocated() {
        let players = [Player(userId: "1", userName: "1", profileImage: PlayerAvatar.blue),
                       Player(userId: "2", userName: "2", profileImage: PlayerAvatar.cyan)]
        let items = [Item(itemType: ItemType.titledItem, category: Category(name: "book"),
                          isInventoryItem: true, isOrderItem: true),
                     Item(itemType: ItemType.titledItem, category: Category(name: "magazine"),
                          isInventoryItem: true, isOrderItem: true),
                     Item(itemType: ItemType.titledItem, category: Category(name: "newspaper"),
                          isInventoryItem: true, isOrderItem: true)]
        let allocator = ItemsAllocator()
        allocator.allocateItems(inventoryItems: items, to: players)
        var allocatedItems = [Item]()
        for player in players {
            allocatedItems.append(contentsOf: Array(player.items))
        }
        XCTAssertEqual(allocatedItems.sorted(), items.sorted())
    }

}
