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
                      isOrderItem: true,
                      imageRepresentation: ImageRepresentation(imageStrings: ["placeholder"]))]
    let mainStrings = ["placeholder"]
    let imageStrings = [Relentless.Category: ImageRepresentation]()
    let isInventoryItem = true
    let isOrderItem = true
    var imageRepresentation: AssembledItemImageRepresentation {
        AssembledItemImageRepresentation(mainImageStrings: mainStrings,
                                         partsImageStrings: imageStrings)
    }

    var assembledItem: AssembledItem {
        AssembledItem(parts: parts, category: sortedCategories[0],
                      isInventoryItem: isInventoryItem,
                      isOrderItem: isOrderItem,
                      imageRepresentation: imageRepresentation)
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
                                                    imageRepresentation: imageRepresentation)
        let itemWithBiggerCategory = AssembledItem(parts: parts, category: sortedCategories[1],
                                                   isInventoryItem: isInventoryItem,
                                                   isOrderItem: isOrderItem,
                                                   imageRepresentation: imageRepresentation)
        XCTAssertTrue(itemWithSmallerCategory < itemWithBiggerCategory)
    }

    func testComparison_betweenDifferentCategories_differentParts() {
        let itemWithSmallerCategory = AssembledItem(parts: parts, category: sortedCategories[0],
                                                    isInventoryItem: isInventoryItem,
                                                    isOrderItem: isOrderItem,
                                                    imageRepresentation: imageRepresentation)
        let itemWithBiggerCategoryButFewerParts = AssembledItem(parts: [], category: sortedCategories[1],
                                                                isInventoryItem: isInventoryItem,
                                                                isOrderItem: isOrderItem,
                                                                imageRepresentation: imageRepresentation)
        XCTAssertTrue(itemWithSmallerCategory < itemWithBiggerCategoryButFewerParts)
    }

    func testEquals_attributesThatAreIncluded() {
        XCTAssertTrue(assembledItem.equals(other: assembledItem))

        let copyOfAssembledItem = AssembledItem(parts: parts, category: sortedCategories[0],
                                                isInventoryItem: isInventoryItem,
                                                isOrderItem: isOrderItem,
                                                imageRepresentation: imageRepresentation)
        XCTAssertTrue(assembledItem.equals(other: copyOfAssembledItem))

        let itemWithDifferentParts = AssembledItem(parts: [], category: sortedCategories[0],
                                                   isInventoryItem: isInventoryItem,
                                                   isOrderItem: isOrderItem,
                                                   imageRepresentation: imageRepresentation)
        XCTAssertFalse(assembledItem.equals(other: itemWithDifferentParts))

        let itemWithDifferentCategory = AssembledItem(parts: parts, category: sortedCategories[1],
                                                      isInventoryItem: isInventoryItem,
                                                      isOrderItem: isOrderItem,
                                                      imageRepresentation: imageRepresentation)
        XCTAssertFalse(assembledItem.equals(other: itemWithDifferentCategory))
    }

    func testEquals_attributesThatAreNotIncluded() {
        let itemWithDifferentIsInventoryStatus = AssembledItem(parts: parts,
                                                               category: sortedCategories[0],
                                                               isInventoryItem: !isInventoryItem,
                                                               isOrderItem: isOrderItem,
                                                               imageRepresentation: imageRepresentation)
        XCTAssertTrue(assembledItem.equals(other: itemWithDifferentIsInventoryStatus))

        let itemWithDifferentIsOrderStatus = AssembledItem(parts: parts,
                                                           category: sortedCategories[0],
                                                           isInventoryItem: isInventoryItem,
                                                           isOrderItem: !isOrderItem,
                                                           imageRepresentation: imageRepresentation)
        XCTAssertTrue(assembledItem.equals(other: itemWithDifferentIsOrderStatus))

        let differentMainImageString =
            AssembledItemImageRepresentation(mainImageStrings: ["placeholder2"],
                                             partsImageStrings: [Relentless.Category: ImageRepresentation]())
        let itemWithDifferentMainImageString = AssembledItem(parts: parts,
                                                             category: sortedCategories[0],
                                                             isInventoryItem: isInventoryItem,
                                                             isOrderItem: isOrderItem,
                                                             imageRepresentation: differentMainImageString)
        XCTAssertTrue(assembledItem.equals(other: itemWithDifferentMainImageString))

        var otherImageStrings = imageStrings
        otherImageStrings[Category(name: "")] = ImageRepresentation(imageStrings: [String]())
        let differentPartImageStrings =
            AssembledItemImageRepresentation(mainImageStrings: ["placeholder"],
                                             partsImageStrings: otherImageStrings)
        let itemWithDifferentImageStrings = AssembledItem(parts: parts,
                                                          category: sortedCategories[0],
                                                          isInventoryItem: isInventoryItem,
                                                          isOrderItem: isOrderItem,
                                                          imageRepresentation: differentPartImageStrings)
        XCTAssertTrue(assembledItem.equals(other: itemWithDifferentImageStrings))
    }
}
