//
//  MagazineTests.swift
//  RelentlessTests
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class TitledItemTests: XCTestCase {
    let title = "Title"
    let imageString = ""

    func testComparison_betweenDifferentCategories_sameName() {
        let magazine = TitledItem(name: title, category: Category(name: "magazine"),
                                  isInventoryItem: true, isOrderItem: true, imageString: imageString)
        let book = TitledItem(name: title, category: Category(name: "book"),
                              isInventoryItem: true, isOrderItem: true, imageString: imageString)
        XCTAssertTrue(book < magazine)
    }

    func testComparison_betweenDifferentCategories_differentName() {
        // magazine has a lexographically smaller title
        let magazine = TitledItem(name: String(title.dropFirst()), category: Category(name: "magazine"),
                                  isInventoryItem: true, isOrderItem: true, imageString: imageString)
        let book = TitledItem(name: title, category: Category(name: "book"),
                              isInventoryItem: true, isOrderItem: true, imageString: imageString)
        XCTAssertTrue(book < magazine)
    }

    func testComparison_betweenSameCategories_differentName() {
        let titledItemWithSmallerName = TitledItem(name: String(title.dropFirst()),
                                                   category: Category(name: "magazine"),
                                                   isInventoryItem: true, isOrderItem: true,
                                                   imageString: imageString)
        let titledItemWithBiggerName = TitledItem(name: title, category: Category(name: "magazine"),
                                                  isInventoryItem: true, isOrderItem: true,
                                                  imageString: imageString)

        XCTAssertTrue(titledItemWithSmallerName < titledItemWithBiggerName)
    }

    func testEquals() {
        let titledItem = TitledItem(name: title, category: Category(name: "book"),
                                    isInventoryItem: true,
                                    isOrderItem: true, imageString: imageString)
        XCTAssertTrue(titledItem.equals(other: titledItem))

        let copyOfTitledItem = TitledItem(name: title, category: Category(name: "book"),
                                          isInventoryItem: true,
                                          isOrderItem: true, imageString: imageString)
        XCTAssertTrue(titledItem.equals(other: copyOfTitledItem))

        let itemWithDifferentTitle = TitledItem(name: title + "a", category: Category(name: "book"),
                                                isInventoryItem: true,
                                                isOrderItem: true, imageString: imageString)
        XCTAssertFalse(titledItem.equals(other: itemWithDifferentTitle))

        let itemWithDifferentCategory = TitledItem(name: title, category: Category(name: "magazine"),
                                                   isInventoryItem: true,
                                                   isOrderItem: true, imageString: imageString)
        XCTAssertFalse(titledItem.equals(other: itemWithDifferentCategory))

        let itemWithDifferentImageString = TitledItem(name: title, category: Category(name: "book"),
                                                      isInventoryItem: true,
                                                      isOrderItem: true, imageString: imageString + "a")
        XCTAssertTrue(titledItem.equals(other: itemWithDifferentImageString))

        let itemWithDifferentIsInventoryStatus = TitledItem(name: title, category: Category(name: "book"),
                                                            isInventoryItem: false, isOrderItem: true,
                                                            imageString: imageString)
        XCTAssertTrue(titledItem.equals(other: itemWithDifferentIsInventoryStatus))

        let itemWithDifferentIsOrderStatus = TitledItem(name: title, category: Category(name: "book"),
                                                        isInventoryItem: true, isOrderItem: false,
                                                        imageString: imageString)
        XCTAssertTrue(titledItem.equals(other: itemWithDifferentIsOrderStatus))

    }

}
