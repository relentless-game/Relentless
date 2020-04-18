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
    
    func testGetTitledItems() throws {
        let actualResult = ItemSpecificationsParser.getTitledItems()
        
        // books
        let bookCategory = Category(name: "book")
        let actualBooks = actualResult[bookCategory]!
        let book1 = TitledItem(name: "The title of the book is", category: bookCategory,
                               isInventoryItem: true, isOrderItem: true,
                               imageString: "bookImage")
        let book2 = TitledItem(name: "The book title is title is", category: bookCategory,
                               isInventoryItem: true, isOrderItem: true,
                               imageString: "bookImage")
        let book3 = TitledItem(name: "The book title", category: bookCategory,
                               isInventoryItem: true, isOrderItem: true,
                               imageString: "bookImage")
        let book4 = TitledItem(name: "Is the book title", category: bookCategory,
                               isInventoryItem: true, isOrderItem: true,
                               imageString: "bookImage")
        let expectedBooks = Set<[TitledItem]>([[book1, book2], [book3, book4]])
        XCTAssertEqual(actualBooks, expectedBooks)
        
        // magazines
        let magazineCategory = Category(name: "magazine")
        let actualMagazines = actualResult[magazineCategory]!
        let magazine1 = TitledItem(name: "By", category: magazineCategory,
                                   isInventoryItem: true, isOrderItem: true,
                                   imageString: "magazineImage")
        let magazine2 = TitledItem(name: "Buy", category: magazineCategory,
                                   isInventoryItem: true, isOrderItem: true,
                                   imageString: "magazineImage")
        let magazine3 = TitledItem(name: "Be", category: magazineCategory,
                                   isInventoryItem: true, isOrderItem: true,
                                   imageString: "magazineImage")
        let magazine4 = TitledItem(name: "Bee", category: magazineCategory,
                                   isInventoryItem: true, isOrderItem: true,
                                   imageString: "magazineImage")
        let expectedMagazines = Set<[TitledItem]>([[magazine1, magazine2], [magazine3, magazine4]])
        XCTAssertEqual(actualMagazines, expectedMagazines)
    }
    
    func testGetRhythmicItems() throws {
        let actualResult = ItemSpecificationsParser.getRhythmicItems()
        
        // robots
        
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
