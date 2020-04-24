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
    let testGameConfigFileName = "TestGameConfig"
    
    func testGetPlist() throws {
        let dict = try ItemSpecificationsParser.getPlist(from: "GameConfig")

        let dictKeys = dict.allKeys as? [String] ?? []
        let expected = ["statefulItems", "titledItems", "rhythmicItems", "assembledItems"]
        
        XCTAssertEqual(dictKeys.sorted(), expected.sorted())
    }
    
    func testGetStatefulItems() throws {
        let itemsDict = try TestItemSpecificationsParser.getPlist(from: testGameConfigFileName)
        let actualResult = ItemSpecificationsParser.getStatefulItems(dict: itemsDict)
        
        // wheels
        let wheelCategory = Category(name: "wheel")
        let actualWheels = actualResult[wheelCategory]!
        let wheel1 = StatefulItem(category: wheelCategory, stateIdentifier: 0,
                                  isInventoryItem: true, isOrderItem: false,
                                  imageString: "circularImage")
        let wheel2 = StatefulItem(category: wheelCategory, stateIdentifier: 1,
                                  isInventoryItem: true, isOrderItem: false,
                                  imageString: "triangularImage")
        let expectedWheels = Set<[StatefulItem]>([[wheel1], [wheel2]])
        XCTAssertEqual(actualWheels, expectedWheels)
        
        // battery
        let batteryCategory = Category(name: "battery")
        let actualBatteries = actualResult[batteryCategory]!
        let battery1 = StatefulItem(category: batteryCategory, stateIdentifier: 0,
                                    isInventoryItem: true, isOrderItem: false,
                                    imageString: "AAImage")
        let battery2 = StatefulItem(category: batteryCategory, stateIdentifier: 1,
                                    isInventoryItem: true, isOrderItem: false,
                                    imageString: "AAAImage")
        let battery3 = StatefulItem(category: batteryCategory, stateIdentifier: 2,
                                    isInventoryItem: true, isOrderItem: false,
                                    imageString: "DImage")
        let battery4 = StatefulItem(category: batteryCategory, stateIdentifier: 3,
                                    isInventoryItem: true, isOrderItem: false,
                                    imageString: "PP3Image")
        let expectedBatteries = Set<[StatefulItem]>([[battery1], [battery2], [battery3], [battery4]])
        XCTAssertEqual(actualBatteries, expectedBatteries)
        
        // carBody
        let carBodyCategory = Category(name: "carBody")
        let actualCarBodies = actualResult[carBodyCategory]!
        let carBody1 = StatefulItem(category: carBodyCategory, stateIdentifier: 0,
                                    isInventoryItem: true, isOrderItem: false,
                                    imageString: "redImage")
        let carBody2 = StatefulItem(category: carBodyCategory, stateIdentifier: 1,
                                    isInventoryItem: true, isOrderItem: false,
                                    imageString: "blueImage")
        let carBody3 = StatefulItem(category: carBodyCategory, stateIdentifier: 2,
                                    isInventoryItem: true, isOrderItem: false,
                                    imageString: "yellowImage")
        let expectedCarBodies = Set<[StatefulItem]>([[carBody1], [carBody2], [carBody3]])
        XCTAssertEqual(actualCarBodies, expectedCarBodies)
        
    }
    
    func testGetTitledItems() throws {
        let itemsDict = try TestItemSpecificationsParser.getPlist(from: testGameConfigFileName)
        let actualResult = ItemSpecificationsParser.getTitledItems(dict: itemsDict)
        
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
        let itemsDict = try TestItemSpecificationsParser.getPlist(from: testGameConfigFileName)
        let actualResult = ItemSpecificationsParser.getRhythmicItems(dict: itemsDict)
        
        // robots
        let robotCategory = Category(name: "robot")
        let actualRobots = actualResult[robotCategory]!
        let unlit = RhythmState(index: 0)
        let lit = RhythmState(index: 1)
        let robot1 = RhythmicItem(unitDuration: 1, stateSequence: [unlit, lit, unlit],
                                  category: robotCategory, isInventoryItem: true,
                                  isOrderItem: true, imageStrings: ["stateZeroImage", "stateOneImage"])
        let robot2 = RhythmicItem(unitDuration: 1, stateSequence: [lit, unlit, lit],
                                  category: robotCategory, isInventoryItem: true,
                                  isOrderItem: true, imageStrings: ["stateZeroImage", "stateOneImage"])
        let robot3 = RhythmicItem(unitDuration: 2, stateSequence: [unlit, lit],
                                  category: robotCategory, isInventoryItem: true,
                                  isOrderItem: true, imageStrings: ["stateZeroImage", "stateOneImage"])
        let robot4 = RhythmicItem(unitDuration: 2, stateSequence: [lit, unlit],
                                  category: robotCategory, isInventoryItem: true,
                                  isOrderItem: true, imageStrings: ["stateZeroImage", "stateOneImage"])
        let expectedRobots = Set<[RhythmicItem]>([[robot1, robot2], [robot3, robot4]])
                
        XCTAssertEqual(actualRobots, expectedRobots)
    }
    
    // swiftlint:disable function_body_length
    func testGetAssembledItems_depth0() throws {
        let category1 = Category(name: "carBody")
        let category2 = Category(name: "wheel")
        let category3 = Category(name: "battery")
        let unlit = RhythmState(index: 0)
        let lit = RhythmState(index: 1)
                
        let titledItem1 = TitledItem(name: "titledItem1", category: category2,
                                     isInventoryItem: true, isOrderItem: true,
                                     imageString: "titledItem1")
        let titledItem2 = TitledItem(name: "titledItem2", category: category2,
                                     isInventoryItem: true, isOrderItem: true,
                                     imageString: "titledItem2")
        let statefulItem1 = StatefulItem(category: category1, stateIdentifier: 0,
                                         isInventoryItem: true, isOrderItem: false,
                                         imageString: "statefulItem1")
        let statefulItem2 = StatefulItem(category: category1, stateIdentifier: 1,
                                         isInventoryItem: true, isOrderItem: false,
                                         imageString: "statefulItem2")
        let rhythmicItem1 = RhythmicItem(unitDuration: 1, stateSequence: [lit],
                                         category: category3, isInventoryItem: true,
                                         isOrderItem: true, imageStrings: ["0", "1"])
        let rhythmicItem2 = RhythmicItem(unitDuration: 2, stateSequence: [unlit],
                                         category: category3, isInventoryItem: true,
                                         isOrderItem: true, imageStrings: ["0", "1"])
        let rhythmicItem3 = RhythmicItem(unitDuration: 3, stateSequence: [unlit, lit],
                                         category: category3, isInventoryItem: true,
                                         isOrderItem: true, imageStrings: ["0", "1"])
        
        let set1 = Set<[Item]>([[titledItem1, titledItem2]])
        let set2 = Set<[Item]>([[statefulItem1], [statefulItem2]])
        let set3 = Set<[Item]>([[rhythmicItem1, rhythmicItem2], [rhythmicItem3]])

        var availableItems: [Relentless.Category: Set<[Item]>] = [:]
        availableItems[category1] = set1
        availableItems[category2] = set2
        availableItems[category3] = set3

        let itemsDict = try TestItemSpecificationsParser.getPlist(from: testGameConfigFileName)
        let actualResult = ItemSpecificationsParser.getAssembledItems(dict: itemsDict,
                                                                      availableAtomicItems: availableItems)
        let toyCarCategory = Category(name: "toyCar")
        let actualAssembledItems = actualResult[toyCarCategory]!
        
        let partsImageStrings = [category1: ["toyCarCarBodyImage"],
                                 category3: ["toyCarBatteryImage"],
                                 category2: ["toyCarWheelImage"]]
        let toyCar1 = AssembledItem(parts: [titledItem1, rhythmicItem1, statefulItem1],
                                    category: toyCarCategory,
                                    isInventoryItem: true, isOrderItem: true,
                                    mainImageString: "toyCarImage",
                                    partsImageStrings: partsImageStrings)
        let toyCar2 = AssembledItem(parts: [titledItem1, rhythmicItem1, statefulItem2],
                                    category: toyCarCategory,
                                    isInventoryItem: true, isOrderItem: true,
                                    mainImageString: "toyCarImage",
                                    partsImageStrings: partsImageStrings)
        let toyCar3 = AssembledItem(parts: [titledItem1, rhythmicItem2, statefulItem1],
                                    category: toyCarCategory,
                                    isInventoryItem: true, isOrderItem: true,
                                    mainImageString: "toyCarImage",
                                    partsImageStrings: partsImageStrings)
        let toyCar4 = AssembledItem(parts: [titledItem1, rhythmicItem2, statefulItem2],
                                    category: toyCarCategory,
                                    isInventoryItem: true, isOrderItem: true,
                                    mainImageString: "toyCarImage",
                                    partsImageStrings: partsImageStrings)
        let toyCar5 = AssembledItem(parts: [titledItem1, rhythmicItem3, statefulItem1],
                                    category: toyCarCategory,
                                    isInventoryItem: true, isOrderItem: true,
                                    mainImageString: "toyCarImage",
                                    partsImageStrings: partsImageStrings)
        let toyCar6 = AssembledItem(parts: [titledItem1, rhythmicItem3, statefulItem2],
                                    category: toyCarCategory,
                                    isInventoryItem: true, isOrderItem: true,
                                    mainImageString: "toyCarImage",
                                    partsImageStrings: partsImageStrings)
        let toyCar7 = AssembledItem(parts: [titledItem2, rhythmicItem1, statefulItem1],
                                    category: toyCarCategory,
                                    isInventoryItem: true, isOrderItem: true,
                                    mainImageString: "toyCarImage",
                                    partsImageStrings: partsImageStrings)
        let toyCar8 = AssembledItem(parts: [titledItem2, rhythmicItem1, statefulItem2],
                                    category: toyCarCategory,
                                    isInventoryItem: true, isOrderItem: true,
                                    mainImageString: "toyCarImage",
                                    partsImageStrings: partsImageStrings)
        let toyCar9 = AssembledItem(parts: [titledItem2, rhythmicItem2, statefulItem1],
                                    category: toyCarCategory,
                                    isInventoryItem: true, isOrderItem: true,
                                    mainImageString: "toyCarImage",
                                    partsImageStrings: partsImageStrings)
        let toyCar10 = AssembledItem(parts: [titledItem2, rhythmicItem2, statefulItem2],
                                     category: toyCarCategory,
                                     isInventoryItem: true, isOrderItem: true,
                                     mainImageString: "toyCarImage",
                                     partsImageStrings: partsImageStrings)
        let toyCar11 = AssembledItem(parts: [titledItem2, rhythmicItem3, statefulItem1],
                                     category: toyCarCategory,
                                     isInventoryItem: true, isOrderItem: true,
                                     mainImageString: "toyCarImage",
                                     partsImageStrings: partsImageStrings)
        let toyCar12 = AssembledItem(parts: [titledItem2, rhythmicItem3, statefulItem2],
                                     category: toyCarCategory,
                                     isInventoryItem: true, isOrderItem: true,
                                     mainImageString: "toyCarImage",
                                     partsImageStrings: partsImageStrings)
        let expectedAssembledItems = Set<[AssembledItem]>([[toyCar1], [toyCar2], [toyCar3], [toyCar4],
                                                           [toyCar5], [toyCar6], [toyCar7], [toyCar8],
                                                           [toyCar9], [toyCar10], [toyCar11], [toyCar12]])
        
        XCTAssertEqual(actualAssembledItems, expectedAssembledItems)
        
    }
    
    // swiftlint:disable function_body_length
    func testGetAssembledItems_depth1() throws {
        let category1 = Category(name: "carBody")
        let category2 = Category(name: "wheel")
        let category3 = Category(name: "battery")
        let category4 = Category(name: "book")
        let unlit = RhythmState(index: 0)
        let lit = RhythmState(index: 1)
                
        let titledItem = TitledItem(name: "titledItem1", category: category2,
                                    isInventoryItem: true, isOrderItem: true,
                                    imageString: "titledItem1")
        let statefulItem = StatefulItem(category: category1, stateIdentifier: 0,
                                        isInventoryItem: true, isOrderItem: false,
                                        imageString: "statefulItem1")
        let rhythmicItem1 = RhythmicItem(unitDuration: 1, stateSequence: [lit],
                                         category: category3, isInventoryItem: true,
                                         isOrderItem: true, imageStrings: ["0", "1"])
        let rhythmicItem2 = RhythmicItem(unitDuration: 2, stateSequence: [unlit],
                                         category: category3, isInventoryItem: true,
                                         isOrderItem: true, imageStrings: ["0", "1"])
        let book1 = TitledItem(name: "book1", category: category4,
                               isInventoryItem: true, isOrderItem: true,
                               imageString: "bookImage")
        let book2 = TitledItem(name: "book1", category: category4,
                               isInventoryItem: true, isOrderItem: true,
                               imageString: "bookImage")
        
        let set1 = Set<[Item]>([[titledItem]])
        let set2 = Set<[Item]>([[statefulItem]])
        let set3 = Set<[Item]>([[rhythmicItem1, rhythmicItem2]])
        let set4 = Set<[Item]>([[book1, book2]])
        
        var availableItems: [Relentless.Category: Set<[Item]>] = [:]
        availableItems[category1] = set1
        availableItems[category2] = set2
        availableItems[category3] = set3
        availableItems[category4] = set4
        
        let itemsDict = try TestItemSpecificationsParser.getPlist(from: testGameConfigFileName)
        let actualResult = ItemSpecificationsParser.getAssembledItems(dict: itemsDict,
                                                                      availableAtomicItems: availableItems)
        let toyCarCategory = Category(name: "toyCar")
        let toyCarGiftCategory = Category(name: "toyCarGift")
        let actualAssembledItems = actualResult[toyCarGiftCategory]!
        
        // expected results
        let partsImageStringsForToyCar = [category1: ["toyCarCarBodyImage"],
                                          category3: ["toyCarBatteryImage"],
                                          category2: ["toyCarWheelImage"]]

        let toyCar1 = AssembledItem(parts: [titledItem, rhythmicItem1, statefulItem],
                                    category: toyCarCategory,
                                    isInventoryItem: true, isOrderItem: true,
                                    mainImageString: "toyCarImage",
                                    partsImageStrings: partsImageStringsForToyCar)
        let toyCar2 = AssembledItem(parts: [titledItem, rhythmicItem2, statefulItem],
                                    category: toyCarCategory,
                                    isInventoryItem: true, isOrderItem: true,
                                    mainImageString: "toyCarImage",
                                    partsImageStrings: partsImageStringsForToyCar)
        
        let partsImageStringsForToyCarGift = [toyCarCategory: ["toyCarImage"],
                                              category4: ["bookImage"]]
        let toyCarGift1 = AssembledItem(parts: [toyCar1, book1], category: toyCarGiftCategory,
                                        isInventoryItem: false, isOrderItem: true,
                                        mainImageString: "toyCarGiftImage",
                                        partsImageStrings: partsImageStringsForToyCarGift)
        let toyCarGift2 = AssembledItem(parts: [toyCar1, book2], category: toyCarGiftCategory,
                                        isInventoryItem: false, isOrderItem: true,
                                        mainImageString: "toyCarGiftImage",
                                        partsImageStrings: partsImageStringsForToyCarGift)
        let toyCarGift3 = AssembledItem(parts: [toyCar2, book1], category: toyCarGiftCategory,
                                        isInventoryItem: false, isOrderItem: true,
                                        mainImageString: "toyCarGiftImage",
                                        partsImageStrings: partsImageStringsForToyCarGift)
        let toyCarGift4 = AssembledItem(parts: [toyCar2, book2], category: toyCarGiftCategory,
                                        isInventoryItem: false, isOrderItem: true,
                                        mainImageString: "toyCarGiftImage",
                                        partsImageStrings: partsImageStringsForToyCarGift)
        let expectedAssembledItems = Set<[AssembledItem]>([[toyCarGift1], [toyCarGift2], [toyCarGift3], [toyCarGift4]])
        
        XCTAssertEqual(actualAssembledItems, expectedAssembledItems)
        
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
        let item4 = StatefulItem(category: category2, stateIdentifier: 0,
                                 isInventoryItem: true, isOrderItem: false,
                                 imageString: "placeholder")
        let item5 = StatefulItem(category: category2, stateIdentifier: 1,
                                 isInventoryItem: true, isOrderItem: false,
                                 imageString: "placeholder")
        
        let availableParts = [[item1, item2, item3], [item4, item5]]
        
        let result = ItemSpecificationsParser.permuteParts(availableParts: availableParts, currentIndex: 0)
        let expected = [[item1, item4], [item1, item5], [item2, item4], [item2, item5],
                        [item3, item4], [item3, item5]]
        XCTAssertEqual(result, expected)
    }

    func testGetStateIdentifierMappings() throws {
        let itemsDict = try TestItemSpecificationsParser.getPlist(from: testGameConfigFileName)
        let actualMappings = ItemSpecificationsParser.getStateIdentifierMappings(dict: itemsDict)
        
        let wheelCategory = Category(name: "wheel")
        let batterCategory = Category(name: "battery")
        let carBodyCategory = Category(name: "carBody")
        
        let expectedMappings = [wheelCategory: [0: "circle", 1: "triangle"],
                                batterCategory: [0: "AA", 1: "AAA", 2: "D", 3: "PP3"],
                                carBodyCategory: [0: "red", 1: "blue", 2: "yellow"]]
        
        XCTAssertEqual(actualMappings, expectedMappings)
    }
    
}
