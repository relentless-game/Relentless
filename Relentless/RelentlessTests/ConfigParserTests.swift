//
//  ItemSpecificationsParserTests.swift
//  RelentlessTests
//
//  Created by Liu Zechu on 12/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class ItemSpecificationsParserTests: XCTestCase {
        
    func testGetPlist() throws {
        let dict = ItemSpecificationsParser.getPlist(from: "GameConfig")

        let dictKeys = dict?.allKeys as? [String] ?? []
        let expected = ["statefulItems", "titledItems", "rhythmicItems", "assembledItems"]
        
        XCTAssertEqual(dictKeys.sorted(), expected.sorted())
    }
    
    func testGetStatefulItems() throws {
        let actualResult = ItemSpecificationsParser.getStatefulItems()
        
        // wheels
        let wheelCategory = Category(name: "wheel")
        let actualWheels = actualResult[wheelCategory]!
        let wheel1 = StatefulItem(category: wheelCategory, stateIdentifier: 1,
                                  isInventoryItem: true, isOrderItem: false,
                                  imageString: "circularImage")
        let wheel2 = StatefulItem(category: wheelCategory, stateIdentifier: 2,
                                  isInventoryItem: true, isOrderItem: false,
                                  imageString: "triangularImage")
        let expectedWheels = Set<[StatefulItem]>([[wheel1], [wheel2]])
        XCTAssertEqual(actualWheels, expectedWheels)
        
        // battery
        let batteryCategory = Category(name: "battery")
        let actualBatteries = actualResult[batteryCategory]!
        let battery1 = StatefulItem(category: batteryCategory, stateIdentifier: 1,
                                    isInventoryItem: true, isOrderItem: false,
                                    imageString: "AAImage")
        let battery2 = StatefulItem(category: batteryCategory, stateIdentifier: 2,
                                    isInventoryItem: true, isOrderItem: false,
                                    imageString: "AAAImage")
        let battery3 = StatefulItem(category: batteryCategory, stateIdentifier: 3,
                                    isInventoryItem: true, isOrderItem: false,
                                    imageString: "DImage")
        let battery4 = StatefulItem(category: batteryCategory, stateIdentifier: 4,
                                    isInventoryItem: true, isOrderItem: false,
                                    imageString: "PP3Image")
        let expectedBatteries = Set<[StatefulItem]>([[battery1], [battery2], [battery3], [battery4]])
        XCTAssertEqual(actualBatteries, expectedBatteries)
        
        // carBody
        let carBodyCategory = Category(name: "carBody")
        let actualCarBodies = actualResult[carBodyCategory]!
        let carBody1 = StatefulItem(category: carBodyCategory, stateIdentifier: 1,
                                    isInventoryItem: true, isOrderItem: false,
                                    imageString: "redImage")
        let carBody2 = StatefulItem(category: carBodyCategory, stateIdentifier: 2,
                                    isInventoryItem: true, isOrderItem: false,
                                    imageString: "blueImage")
        let carBody3 = StatefulItem(category: carBodyCategory, stateIdentifier: 3,
                                    isInventoryItem: true, isOrderItem: false,
                                    imageString: "yellowImage")
        let expectedCarBodies = Set<[StatefulItem]>([[carBody1], [carBody2], [carBody3]])
        XCTAssertEqual(actualCarBodies, expectedCarBodies)
        
    }
    
    func testPermuteParts() throws {
        let category1 = Category(name: "book")
        let category2 = Category(name: "wheel")

        let item1 = TitledItem(name: "1", category: category1,
                               isInventoryItem: true, isOrderItem: true,
                               imageString: "placeholder")
        let item2 = TitledItem(name: "2", category: category1,
                               isInventoryItem: true, isOrderItem: true,
                               imageString: "placeholder")
        let item3 = TitledItem(name: "3", category: category1,
                               isInventoryItem: true, isOrderItem: true,
                               imageString: "placeholder")
        let item4 = StatefulItem(category: category2, stateIdentifier: 1,
                                 isInventoryItem: true, isOrderItem: false,
                                 imageString: "placeholder")
        let item5 = StatefulItem(category: category2, stateIdentifier: 2,
                                 isInventoryItem: true, isOrderItem: false,
                                 imageString: "placeholder")
        
        let availableParts = [[item1, item2, item3], [item4, item5]]
        
        let result = ItemSpecificationsParser.permuteParts(availableParts: availableParts, currentIndex: 0)
        let expected = [[item1, item4], [item1, item5], [item2, item4], [item2, item5],
                        [item3, item4], [item3, item5]]
        XCTAssertEqual(result, expected)
    }

}
