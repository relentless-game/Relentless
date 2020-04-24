//
//  StatefulItemTests.swift
//  RelentlessTests
//
//  Created by Chow Yi Yin on 19/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class StatefulItemTests: XCTestCase {
    let stateIdentifier = 1
    let imageString = ""
    let isInventoryItem = true
    let isOrderItem = true
    var sortedCategories: [Relentless.Category]!

    override func setUp() {
        super.setUp()
        let categories = [Category(name: "wheel"), Category(name: "battery")]
        sortedCategories = categories.sorted()
    }

    func testComparison_betweenDifferentCategories_sameIdentifier() {
        let itemWithSmallerCategory = StatefulItem(category: sortedCategories[0],
                                                   stateIdentifier: stateIdentifier,
                                                   isInventoryItem: isInventoryItem,
                                                   isOrderItem: isOrderItem, imageString: imageString)
        let itemWithBiggerCategory = StatefulItem(category: sortedCategories[1],
                                                  stateIdentifier: stateIdentifier,
                                                  isInventoryItem: isInventoryItem,
                                                  isOrderItem: isOrderItem, imageString: imageString)
        XCTAssertTrue(itemWithSmallerCategory < itemWithBiggerCategory)
    }

    func testComparison_betweenDifferentCategories_differentIdentifier() {
        let itemWithSmallerCategory = StatefulItem(category: sortedCategories[0],
                                                   stateIdentifier: stateIdentifier,
                                                   isInventoryItem: isInventoryItem,
                                                   isOrderItem: isOrderItem, imageString: imageString)
        let itemWithBiggerCategoryButSmallerIdentifier = StatefulItem(category: sortedCategories[1],
                                                                      stateIdentifier: stateIdentifier + 1,
                                                                      isInventoryItem: isInventoryItem,
                                                                      isOrderItem: isOrderItem,
                                                                      imageString: imageString)
        XCTAssertTrue(itemWithSmallerCategory < itemWithBiggerCategoryButSmallerIdentifier)
    }

    func testComparison_betweenSameCategories_differentIdentifier() {
        let itemWithSmallerIdentifier = StatefulItem(category: sortedCategories[0],
                                                     stateIdentifier: stateIdentifier,
                                                     isInventoryItem: isInventoryItem,
                                                     isOrderItem: isOrderItem, imageString: imageString)
        let itemWithBiggerIdentifier = StatefulItem(category: sortedCategories[0],
                                                    stateIdentifier: stateIdentifier + 1,
                                                    isInventoryItem: isInventoryItem,
                                                    isOrderItem: isOrderItem, imageString: imageString)

        XCTAssertTrue(itemWithSmallerIdentifier < itemWithBiggerIdentifier)
    }

    func testEquals() {
        let statefulItem = StatefulItem(category: sortedCategories[0],
                                        stateIdentifier: stateIdentifier,
                                        isInventoryItem: isInventoryItem,
                                        isOrderItem: isOrderItem, imageString: imageString)
        XCTAssertTrue(statefulItem.equals(other: statefulItem))

        let copyOfStatefulItem = StatefulItem(category: sortedCategories[0],
                                              stateIdentifier: stateIdentifier,
                                              isInventoryItem: isInventoryItem,
                                              isOrderItem: isOrderItem, imageString: imageString)
        XCTAssertTrue(statefulItem.equals(other: copyOfStatefulItem))

        let itemWithDifferentIdentifier = StatefulItem(category: sortedCategories[0],
                                                       stateIdentifier: stateIdentifier + 1,
                                                       isInventoryItem: isInventoryItem,
                                                       isOrderItem: isOrderItem, imageString: imageString)
        XCTAssertFalse(statefulItem.equals(other: itemWithDifferentIdentifier))

        let itemWithDifferentCategory = StatefulItem(category: sortedCategories[0],
                                                     stateIdentifier: stateIdentifier + 1,
                                                     isInventoryItem: isInventoryItem,
                                                     isOrderItem: isOrderItem, imageString: imageString)
        XCTAssertFalse(statefulItem.equals(other: itemWithDifferentCategory))

        let itemWithDifferentIsInventoryStatus = StatefulItem(category: sortedCategories[0],
                                                              stateIdentifier: stateIdentifier,
                                                              isInventoryItem: !isInventoryItem,
                                                              isOrderItem: isOrderItem,
                                                              imageString: imageString)
        XCTAssertTrue(statefulItem.equals(other: itemWithDifferentIsInventoryStatus))

        let itemWithDifferentIsOrderStatus = StatefulItem(category: sortedCategories[0],
                                                          stateIdentifier: stateIdentifier,
                                                          isInventoryItem: isInventoryItem,
                                                          isOrderItem: !isOrderItem,
                                                          imageString: imageString)
        XCTAssertTrue(statefulItem.equals(other: itemWithDifferentIsOrderStatus))

        let itemWithDifferentImageString = StatefulItem(category: sortedCategories[0],
                                                        stateIdentifier: stateIdentifier,
                                                        isInventoryItem: isInventoryItem,
                                                        isOrderItem: isOrderItem,
                                                        imageString: imageString + "a")
        XCTAssertTrue(statefulItem.equals(other: itemWithDifferentImageString))
    }
}
