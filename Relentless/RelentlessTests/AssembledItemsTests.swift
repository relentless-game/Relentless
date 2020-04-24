//
//  AssembledItemsTests.swift
//  RelentlessTests
//
//  Created by Chow Yi Yin on 20/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class AssembledItemsTests: XCTestCase {
    let parts = [Item(itemType: ItemType.assembledItem,
                      category: Category(name: "robot"),
                      isInventoryItem: true,
                      isOrderItem: true)]
    let mainString = ""
    let imageStrings = [Relentless.Category: String]()
    let isInventoryItem = true
    let isOrderItem = true
    var assembledItem: AssembledItem {
        AssembledItem(parts: parts, category: sortedCategories[0],
                      isInventoryItem: isInventoryItem,
                      isOrderItem: isOrderItem,
                      mainImageString: mainString,
                      partsImageStrings: imageStrings)
    }
    var sortedCategories: [Relentless.Category]!

    override func setUp() {
        super.setUp()
        let categories = [Category(name: "toyCar"), Category(name: "legoCastle")]
        sortedCategories = categories.sorted()
    }

    func testComparison_betweenDifferentCategories_sameDurationAndStateSequence() {
        let itemWithSmallerCategory = AssembledItem(parts: parts, category: sortedCategories[0],
                                                    isInventoryItem: isInventoryItem,
                                                    isOrderItem: isOrderItem,
                                                    mainImageString: mainString,
                                                    partsImageStrings: imageStrings)
        let itemWithBiggerCategory = AssembledItem(parts: parts, category: sortedCategories[1],
                                                   isInventoryItem: isInventoryItem,
                                                   isOrderItem: isOrderItem,
                                                   mainImageString: mainString,
                                                   partsImageStrings: imageStrings)
        XCTAssertTrue(itemWithSmallerCategory < itemWithBiggerCategory)
    }

    func testComparison_betweenDifferentCategories_differentParts() {
        let itemWithSmallerCategory = AssembledItem(parts: parts, category: sortedCategories[0],
                                                    isInventoryItem: isInventoryItem,
                                                    isOrderItem: isOrderItem,
                                                    mainImageString: mainString,
                                                    partsImageStrings: imageStrings)
        let itemWithBiggerCategoryButFewerParts = AssembledItem(parts: [], category: sortedCategories[1],
                                                                isInventoryItem: isInventoryItem,
                                                                isOrderItem: isOrderItem,
                                                                mainImageString: mainString,
                                                                partsImageStrings: imageStrings)
        XCTAssertTrue(itemWithSmallerCategory < itemWithBiggerCategoryButFewerParts)
    }

    func testEquals_attributesThatAreIncluded() {
        XCTAssertTrue(assembledItem.equals(other: assembledItem))

        let copyOfAssembledItem = AssembledItem(parts: parts, category: sortedCategories[0],
                                                isInventoryItem: isInventoryItem,
                                                isOrderItem: isOrderItem,
                                                mainImageString: mainString,
                                                partsImageStrings: imageStrings)
        XCTAssertTrue(assembledItem.equals(other: copyOfAssembledItem))

        let itemWithDifferentParts = AssembledItem(parts: [], category: sortedCategories[0],
                                                   isInventoryItem: isInventoryItem,
                                                   isOrderItem: isOrderItem,
                                                   mainImageString: mainString,
                                                   partsImageStrings: imageStrings)
        XCTAssertFalse(assembledItem.equals(other: itemWithDifferentParts))

        let itemWithDifferentCategory = AssembledItem(parts: parts, category: sortedCategories[1],
                                                      isInventoryItem: isInventoryItem,
                                                      isOrderItem: isOrderItem,
                                                      mainImageString: mainString,
                                                      partsImageStrings: imageStrings)
        XCTAssertFalse(assembledItem.equals(other: itemWithDifferentCategory))
    }

    func testEquals_attributesThatAreNotIncluded() {
        let itemWithDifferentIsInventoryStatus = AssembledItem(parts: parts,
                                                               category: sortedCategories[0],
                                                               isInventoryItem: !isInventoryItem,
                                                               isOrderItem: isOrderItem,
                                                               mainImageString: mainString,
                                                               partsImageStrings: imageStrings)
        XCTAssertTrue(assembledItem.equals(other: itemWithDifferentIsInventoryStatus))

        let itemWithDifferentIsOrderStatus = AssembledItem(parts: parts,
                                                           category: sortedCategories[0],
                                                           isInventoryItem: isInventoryItem,
                                                           isOrderItem: !isOrderItem,
                                                           mainImageString: mainString,
                                                           partsImageStrings: imageStrings)
        XCTAssertTrue(assembledItem.equals(other: itemWithDifferentIsOrderStatus))

        let itemWithDifferentImageString = AssembledItem(parts: parts,
                                                         category: sortedCategories[0],
                                                         isInventoryItem: isInventoryItem,
                                                         isOrderItem: isOrderItem,
                                                         mainImageString: mainString + "a",
                                                         partsImageStrings: imageStrings)
        XCTAssertTrue(assembledItem.equals(other: itemWithDifferentImageString))

        var otherImageStrings = imageStrings
        otherImageStrings[Category(name: "")] = ""
        let itemWithDifferentImageStrings = AssembledItem(parts: parts,
                                                          category: sortedCategories[0],
                                                          isInventoryItem: isInventoryItem,
                                                          isOrderItem: isOrderItem,
                                                          mainImageString: mainString + "a",
                                                          partsImageStrings: otherImageStrings)
        XCTAssertTrue(assembledItem.equals(other: itemWithDifferentImageStrings))
    }
}
