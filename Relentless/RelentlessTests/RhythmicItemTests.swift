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
    let stateSequence = [RhythmState(index: 0), RhythmState(index: 1)]
    let imageRepresentation = ImageRepresentation(imageStrings: [""])
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
                                    imageRepresentation: imageRepresentation)
    }

    func testComparison_betweenDifferentCategories_sameDurationAndStateSequence() {
        let itemWithSmallerCategory = RhythmicItem(unitDuration: unitDuration,
                                                   stateSequence: stateSequence,
                                                   category: sortedCategories[0],
                                                   isInventoryItem: isInventoryItem,
                                                   isOrderItem: isOrderItem,
                                                   imageRepresentation: imageRepresentation)

        let itemWithBiggerCategory = RhythmicItem(unitDuration: unitDuration,
                                                  stateSequence: stateSequence,
                                                  category: sortedCategories[1],
                                                  isInventoryItem: isInventoryItem,
                                                  isOrderItem: isOrderItem,
                                                  imageRepresentation: imageRepresentation)
        XCTAssertTrue(itemWithSmallerCategory < itemWithBiggerCategory)
    }

    func testComparison_betweenDifferentCategories_differentDuration() {
        let itemWithSmallerCategory = RhythmicItem(unitDuration: unitDuration,
                                                   stateSequence: stateSequence,
                                                   category: sortedCategories[0],
                                                   isInventoryItem: isInventoryItem,
                                                   isOrderItem: isOrderItem,
                                                   imageRepresentation: imageRepresentation)
        let itemWithBiggerCategoryButSmallerUnitDuration = RhythmicItem(unitDuration: unitDuration - 1,
                                                                        stateSequence: stateSequence,
                                                                        category: sortedCategories[1],
                                                                        isInventoryItem: isInventoryItem,
                                                                        isOrderItem: isOrderItem,
                                                                        imageRepresentation: imageRepresentation)
        XCTAssertTrue(itemWithSmallerCategory < itemWithBiggerCategoryButSmallerUnitDuration)
    }

    func testComparison_betweenSameCategories_differentUnitDuration() {
        let itemWithSmallerDuration = RhythmicItem(unitDuration: unitDuration,
                                                   stateSequence: stateSequence,
                                                   category: sortedCategories[0],
                                                   isInventoryItem: isInventoryItem,
                                                   isOrderItem: isOrderItem,
                                                   imageRepresentation: imageRepresentation)
        let itemWithLongerDuration = RhythmicItem(unitDuration: unitDuration + 1,
                                                  stateSequence: stateSequence,
                                                  category: sortedCategories[0],
                                                  isInventoryItem: isInventoryItem,
                                                  isOrderItem: isOrderItem,
                                                  imageRepresentation: imageRepresentation)
        XCTAssertTrue(itemWithSmallerDuration < itemWithLongerDuration)
    }

    func testComparison_betweenSameCategories_sameDurationDifferentSequence() {
        let itemWithSmallerSequence = RhythmicItem(unitDuration: unitDuration,
                                                   stateSequence: stateSequence.sorted(),
                                                   category: sortedCategories[0],
                                                   isInventoryItem: isInventoryItem,
                                                   isOrderItem: isOrderItem,
                                                   imageRepresentation: imageRepresentation)
        var largerSequence = stateSequence
        largerSequence.append(RhythmState(index: 1))
        let itemWithLargerSequence = RhythmicItem(unitDuration: unitDuration,
                                                  stateSequence: largerSequence,
                                                  category: sortedCategories[0],
                                                  isInventoryItem: isInventoryItem,
                                                  isOrderItem: isOrderItem,
                                                  imageRepresentation: imageRepresentation)
        XCTAssertTrue(itemWithSmallerSequence < itemWithLargerSequence)
    }

    func testComparison_betweenSameCategories_sameDurationDifferentSequenceButSameMagnitude() {
        let itemWithSmallerSequence = RhythmicItem(unitDuration: unitDuration,
                                                   stateSequence: stateSequence.sorted(),
                                                   category: sortedCategories[0],
                                                   isInventoryItem: isInventoryItem,
                                                   isOrderItem: isOrderItem,
                                                   imageRepresentation: imageRepresentation)
        var largerSequence = stateSequence
        largerSequence.append(RhythmState(index: 0))
        let itemWithLargerSequence = RhythmicItem(unitDuration: unitDuration,
                                                  stateSequence: largerSequence,
                                                  category: sortedCategories[0],
                                                  isInventoryItem: isInventoryItem,
                                                  isOrderItem: isOrderItem,
                                                  imageRepresentation: imageRepresentation)
        XCTAssertFalse(itemWithSmallerSequence < itemWithLargerSequence)
    }

    func testEquals_attributesThatAreIncluded() {
        XCTAssertTrue(rhythmicItem.equals(other: rhythmicItem))

        let copyOfRhythmicItem = RhythmicItem(unitDuration: unitDuration,
                                              stateSequence: stateSequence,
                                              category: sortedCategories[0],
                                              isInventoryItem: isInventoryItem,
                                              isOrderItem: isOrderItem,
                                              imageRepresentation: imageRepresentation)
        XCTAssertTrue(rhythmicItem.equals(other: copyOfRhythmicItem))

        let itemWithDifferentUnitDuration = RhythmicItem(unitDuration: unitDuration + 1,
                                                         stateSequence: stateSequence,
                                                         category: sortedCategories[0],
                                                         isInventoryItem: isInventoryItem,
                                                         isOrderItem: isOrderItem,
                                                         imageRepresentation: imageRepresentation)
        XCTAssertFalse(rhythmicItem.equals(other: itemWithDifferentUnitDuration))

        var otherSequence = stateSequence
        otherSequence.append(RhythmState(index: 0))
        let itemWithDifferentSequence = RhythmicItem(unitDuration: unitDuration,
                                                     stateSequence: otherSequence,
                                                     category: sortedCategories[0],
                                                     isInventoryItem: isInventoryItem,
                                                     isOrderItem: isOrderItem,
                                                     imageRepresentation: imageRepresentation)
        XCTAssertFalse(rhythmicItem.equals(other: itemWithDifferentSequence))

        let itemWithDifferentCategory = RhythmicItem(unitDuration: unitDuration,
                                                     stateSequence: stateSequence,
                                                     category: sortedCategories[1],
                                                     isInventoryItem: isInventoryItem,
                                                     isOrderItem: isOrderItem,
                                                     imageRepresentation: imageRepresentation)
        XCTAssertFalse(rhythmicItem.equals(other: itemWithDifferentCategory))
    }

    func testEquals_attributesThatAreNotIncluded() {
        let itemWithDifferentIsInventoryStatus = RhythmicItem(unitDuration: unitDuration,
                                                              stateSequence: stateSequence,
                                                              category: sortedCategories[0],
                                                              isInventoryItem: !isInventoryItem,
                                                              isOrderItem: isOrderItem,
                                                              imageRepresentation: imageRepresentation)
        XCTAssertTrue(rhythmicItem.equals(other: itemWithDifferentIsInventoryStatus))

        let itemWithDifferentIsOrderStatus = RhythmicItem(unitDuration: unitDuration,
                                                          stateSequence: stateSequence,
                                                          category: sortedCategories[0],
                                                          isInventoryItem: isInventoryItem,
                                                          isOrderItem: !isOrderItem,
                                                          imageRepresentation: imageRepresentation)
        XCTAssertTrue(rhythmicItem.equals(other: itemWithDifferentIsOrderStatus))

        let differentImageRepresentation = ImageRepresentation(imageStrings: ["a"])
        let itemWithDifferentImageStrings = RhythmicItem(unitDuration: unitDuration,
                                                         stateSequence: stateSequence,
                                                         category: sortedCategories[0],
                                                         isInventoryItem: isInventoryItem,
                                                         isOrderItem: isOrderItem,
                                                         imageRepresentation: differentImageRepresentation)
        XCTAssertTrue(rhythmicItem.equals(other: itemWithDifferentImageStrings))
    }
}
