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
    func testEncodeItems_emptyItems() {
        let result = ItemsAdapter.encodeItems(items: [])
        XCTAssertEqual(result!, "{\"items\":[]}")
    }
    
    func testEncodeItemsThenDecodeItems() {
        let item1 = Book(name: "book1")
        let item2 = Book(name: "book2")
        let item3 = Book(name: "book3")
        let item4 = Book(name: "book4")
        let item5 = Magazine(name: "mag1")
        let item6 = Magazine(name: "mag2")
        let item7 = Magazine(name: "mag3")
        let items = [item1, item2, item3, item4, item5, item6, item7]
        
        let encodedString = ItemsAdapter.encodeItems(items: items)!
        let decodedItems = ItemsAdapter.decodeItems(from: encodedString)
        
        XCTAssertEqual(decodedItems, items)
    }
}
