//
//  ItemsAdapterTests.swift
//  RelentlessTests
//
//  Created by Liu Zechu on 22/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class ItemsAdapterTests: XCTestCase {
    let imageRepresentation = ImageRepresentation(imageStrings: ["placeholder"])

    func testEncodeItems_emptyItems() {
        let result = ItemsAdapter.encodeItems(items: [])
        XCTAssertEqual(result!, "{\"items\":[]}")
    }
    
    func testEncodeItemsThenDecodeItems() {
        let item1 = TitledItem(name: "1", category: Category(name: "book"),
                               isInventoryItem: true, isOrderItem: true,
                               imageRepresentation: imageRepresentation)
        let item2 = TitledItem(name: "2", category: Category(name: "book"),
                               isInventoryItem: true, isOrderItem: true,
                               imageRepresentation: imageRepresentation)
        let item3 = TitledItem(name: "3", category: Category(name: "book"),
                               isInventoryItem: true, isOrderItem: true,
                               imageRepresentation: imageRepresentation)
        let item4 = StatefulItem(category: Category(name: "wheel"), stateIdentifier: 1,
                                 isInventoryItem: true, isOrderItem: false,
                                 imageRepresentation: imageRepresentation)
        let item5 = StatefulItem(category: Category(name: "wheel"), stateIdentifier: 2,
                                 isInventoryItem: true, isOrderItem: false,
                                 imageRepresentation: imageRepresentation)

        let items = [item1, item2, item3, item4, item5]
        
        let encodedString = ItemsAdapter.encodeItems(items: items)!
        let decodedItems = ItemsAdapter.decodeItems(from: encodedString)
        
        XCTAssertEqual(decodedItems, items)
    }
}
