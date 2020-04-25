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
    let imageRepresentation = ImageRepresentation(imageStrings: [""])
    let isInventoryItem = true
    let isOrderItem = true
    var sortedCategories: [Relentless.Category]!

    override func setUp() {
        super.setUp()
        let categories = [Category(name: "book"), Category(name: "magazine")]
        sortedCategories = categories.sorted()
    }

    func testComparison_betweenDifferentCategories_sameName() {
        let itemWithSmallerCategory = TitledItem(name: title, category: sortedCategories[0],
                                                 isInventoryItem: isInventoryItem,
                                                 isOrderItem: isOrderItem,
                                                 imageRepresentation: imageRepresentation)
        let itemWithBiggerCategory = TitledItem(name: title, category: sortedCategories[1],
                                                isInventoryItem: isInventoryItem,
                                                isOrderItem: isOrderItem,
                                                imageRepresentation: imageRepresentation)
        XCTAssertTrue(itemWithSmallerCategory < itemWithBiggerCategory)
    }

    func testComparison_betweenDifferentCategories_differentName() {
        let itemWithSmallerCategory = TitledItem(name: title, category: sortedCategories[0],
                                                 isInventoryItem: isInventoryItem,
                                                 isOrderItem: isOrderItem,
                                                 imageRepresentation: imageRepresentation)
        let itemWithBiggerCategoryButSmallerName = TitledItem(name: String(title.dropFirst()),
                                                              category: sortedCategories[1],
                                                              isInventoryItem: isInventoryItem,
                                                              isOrderItem: isOrderItem,
                                                              imageRepresentation: imageRepresentation)
        XCTAssertTrue(itemWithSmallerCategory < itemWithBiggerCategoryButSmallerName)
    }

    func testComparison_betweenSameCategories_differentName() {
        let titledItemWithSmallerName = TitledItem(name: String(title.dropFirst()),
                                                   category: sortedCategories[0],
                                                   isInventoryItem: isInventoryItem,
                                                   isOrderItem: isOrderItem,
                                                   imageRepresentation: imageRepresentation)
        let titledItemWithBiggerName = TitledItem(name: title, category: sortedCategories[0],
                                                  isInventoryItem: isInventoryItem,
                                                  isOrderItem: isOrderItem,
                                                  imageRepresentation: imageRepresentation)

        XCTAssertTrue(titledItemWithSmallerName < titledItemWithBiggerName)
    }

    func testEquals() {
        let titledItem = TitledItem(name: title, category: sortedCategories[0],
                                    isInventoryItem: isInventoryItem,
                                    isOrderItem: isOrderItem,
                                    imageRepresentation: imageRepresentation)
        XCTAssertTrue(titledItem.equals(other: titledItem))

        let copyOfTitledItem = TitledItem(name: title, category: sortedCategories[0],
                                          isInventoryItem: isInventoryItem,
                                          isOrderItem: isOrderItem,
                                          imageRepresentation: imageRepresentation)
        XCTAssertTrue(titledItem.equals(other: copyOfTitledItem))

        let itemWithDifferentTitle = TitledItem(name: title + "a", category: sortedCategories[0],
                                                isInventoryItem: isInventoryItem,
                                                isOrderItem: isOrderItem,
                                                imageRepresentation: imageRepresentation)
        XCTAssertFalse(titledItem.equals(other: itemWithDifferentTitle))

        let itemWithDifferentCategory = TitledItem(name: title, category: sortedCategories[1],
                                                   isInventoryItem: isInventoryItem,
                                                   isOrderItem: isOrderItem,
                                                   imageRepresentation: imageRepresentation)
        XCTAssertFalse(titledItem.equals(other: itemWithDifferentCategory))

        let itemWithDifferentIsInventoryStatus = TitledItem(name: title, category: sortedCategories[0],
                                                            isInventoryItem: !isInventoryItem,
                                                            isOrderItem: isOrderItem,
                                                            imageRepresentation: imageRepresentation)
        XCTAssertTrue(titledItem.equals(other: itemWithDifferentIsInventoryStatus))

        let itemWithDifferentIsOrderStatus = TitledItem(name: title, category: sortedCategories[0],
                                                        isInventoryItem: isInventoryItem,
                                                        isOrderItem: !isOrderItem,
                                                        imageRepresentation: imageRepresentation)
        XCTAssertTrue(titledItem.equals(other: itemWithDifferentIsOrderStatus))

        let differentImageRepresentation = ImageRepresentation(imageStrings: ["a"])
        let itemWithDifferentImageString = TitledItem(name: title, category: sortedCategories[0],
                                                      isInventoryItem: isInventoryItem,
                                                      isOrderItem: isOrderItem,
                                                      imageRepresentation: differentImageRepresentation)
        XCTAssertTrue(titledItem.equals(other: itemWithDifferentImageString))
    }
}
