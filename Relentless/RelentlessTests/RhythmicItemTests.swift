//
//  RhythmicItemTests.swift
//  RelentlessTests
//
//  Created by Chow Yi Yin on 20/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class RhythmicItemTests: XCTestCase {
    let unitDuration = 1
    let stateSequence = [RhythmState.lit, RhythmState.unlit]
    let imageStrings = [String]()
    let isInventoryItem = true
    let isOrderItem = true
    
    var rhythmicItem: RhythmicItem!
    var sortedCategories: [Relentless.Category]!

    override func setUp() {
        super.setUp()
        let categories = [Category(name: "robot"), Category(name: "siren")]
        sortedCategories = categories.sorted()
        rhythmicItem = RhythmicItem(unitDuration: unitDuration,
                                    stateSequence: stateSequence,
                                    category: sortedCategories[0],
                                    isInventoryItem: isInventoryItem,
                                    isOrderItem: isOrderItem,
                                    imageStrings: imageStrings)
    }

    func testComparison_betweenDifferentCategories_sameDurationAndStateSequence() {
        let itemWithSmallerCategory = RhythmicItem(unitDuration: unitDuration,
                                                   stateSequence: stateSequence,
                                                   category: sortedCategories[0],
                                                   isInventoryItem: isInventoryItem,
                                                   isOrderItem: isOrderItem, imageStrings: imageStrings)
        let itemWithBiggerCategory = RhythmicItem(unitDuration: unitDuration,
                                                  stateSequence: stateSequence,
                                                  category: sortedCategories[1],
                                                  isInventoryItem: isInventoryItem,
                                                  isOrderItem: isOrderItem, imageStrings: imageStrings)
        XCTAssertTrue(itemWithSmallerCategory < itemWithBiggerCategory)
    }

    func testComparison_betweenDifferentCategories_differentDuration() {
        let itemWithSmallerCategory = RhythmicItem(unitDuration: unitDuration,
                                                   stateSequence: stateSequence,
                                                   category: sortedCategories[0],
                                                   isInventoryItem: isInventoryItem,
                                                   isOrderItem: isOrderItem, imageStrings: imageStrings)
        let itemWithBiggerCategoryButSmallerUnitDuration = RhythmicItem(unitDuration: unitDuration - 1,
                                                                        stateSequence: stateSequence,
                                                                        category: sortedCategories[1],
                                                                        isInventoryItem: isInventoryItem,
                                                                        isOrderItem: isOrderItem,
                                                                        imageStrings: imageStrings)
        XCTAssertTrue(itemWithSmallerCategory < itemWithBiggerCategoryButSmallerUnitDuration)
    }

    func testComparison_betweenSameCategories_differentUnitDuration() {
        let itemWithSmallerDuration = RhythmicItem(unitDuration: unitDuration,
                                                   stateSequence: stateSequence,
                                                   category: sortedCategories[0],
                                                   isInventoryItem: isInventoryItem,
                                                   isOrderItem: isOrderItem, imageStrings: imageStrings)
        let itemWithLongerDuration = RhythmicItem(unitDuration: unitDuration + 1,
                                                  stateSequence: stateSequence,
                                                  category: sortedCategories[0],
                                                  isInventoryItem: isInventoryItem,
                                                  isOrderItem: isOrderItem, imageStrings: imageStrings)

        XCTAssertTrue(itemWithSmallerDuration < itemWithLongerDuration)
    }

    func testComparison_betweenSameCategories_sameDurationDifferentSequence() {
        let itemWithSmallerSequence = RhythmicItem(unitDuration: unitDuration,
                                                   stateSequence: stateSequence.sorted(),
                                                   category: sortedCategories[0],
                                                   isInventoryItem: isInventoryItem,
                                                   isOrderItem: isOrderItem, imageStrings: imageStrings)
        let itemWithLargerSequence = RhythmicItem(unitDuration: unitDuration,
                                                  stateSequence: stateSequence.sorted().reversed(),
                                                  category: sortedCategories[0],
                                                  isInventoryItem: isInventoryItem,
                                                  isOrderItem: isOrderItem, imageStrings: imageStrings)

        XCTAssertTrue(itemWithSmallerSequence < itemWithLargerSequence)
    }

    func testEquals_attributesThatAreIncluded() {
        XCTAssertTrue(rhythmicItem.equals(other: rhythmicItem))

        let copyOfRhythmicItem = RhythmicItem(unitDuration: unitDuration,
                                              stateSequence: stateSequence,
                                              category: sortedCategories[0],
                                              isInventoryItem: isInventoryItem,
                                              isOrderItem: isOrderItem,
                                              imageStrings: imageStrings)
        XCTAssertTrue(rhythmicItem.equals(other: copyOfRhythmicItem))

        let itemWithDifferentUnitDuration = RhythmicItem(unitDuration: unitDuration + 1,
                                                         stateSequence: stateSequence,
                                                         category: sortedCategories[0],
                                                         isInventoryItem: isInventoryItem,
                                                         isOrderItem: isOrderItem,
                                                         imageStrings: imageStrings)
        XCTAssertFalse(rhythmicItem.equals(other: itemWithDifferentUnitDuration))

        var otherSequence = stateSequence
        otherSequence.append(RhythmState.lit)
        let itemWithDifferentSequence = RhythmicItem(unitDuration: unitDuration,
                                                     stateSequence: otherSequence,
                                                     category: sortedCategories[0],
                                                     isInventoryItem: isInventoryItem,
                                                     isOrderItem: isOrderItem,
                                                     imageStrings: imageStrings)
        XCTAssertFalse(rhythmicItem.equals(other: itemWithDifferentSequence))

        let itemWithDifferentCategory = RhythmicItem(unitDuration: unitDuration,
                                                     stateSequence: stateSequence,
                                                     category: sortedCategories[1],
                                                     isInventoryItem: isInventoryItem,
                                                     isOrderItem: isOrderItem,
                                                     imageStrings: imageStrings)
        XCTAssertFalse(rhythmicItem.equals(other: itemWithDifferentCategory))
    }

    func testEquals_attributesThatAreNotIncluded() {
        let itemWithDifferentIsInventoryStatus = RhythmicItem(unitDuration: unitDuration,
                                                              stateSequence: stateSequence,
                                                              category: sortedCategories[0],
                                                              isInventoryItem: !isInventoryItem,
                                                              isOrderItem: isOrderItem,
                                                              imageStrings: imageStrings)
        XCTAssertTrue(rhythmicItem.equals(other: itemWithDifferentIsInventoryStatus))

        let itemWithDifferentIsOrderStatus = RhythmicItem(unitDuration: unitDuration,
                                                          stateSequence: stateSequence,
                                                          category: sortedCategories[0],
                                                          isInventoryItem: isInventoryItem,
                                                          isOrderItem: !isOrderItem,
                                                          imageStrings: imageStrings)
        XCTAssertTrue(rhythmicItem.equals(other: itemWithDifferentIsOrderStatus))

        var otherImageStrings = imageStrings
        otherImageStrings.append("")
        let itemWithDifferentImageStrings = RhythmicItem(unitDuration: unitDuration,
                                                         stateSequence: stateSequence,
                                                         category: sortedCategories[0],
                                                         isInventoryItem: isInventoryItem,
                                                         isOrderItem: isOrderItem,
                                                         imageStrings: otherImageStrings)
        XCTAssertTrue(rhythmicItem.equals(other: itemWithDifferentImageStrings))
    }
}
