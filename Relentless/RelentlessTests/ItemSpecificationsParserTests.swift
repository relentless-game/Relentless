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
    let imageRepresentationPlaceholder = ImageRepresentation(imageStrings: ["placeholder"])
    let bookImageRepresentation = ImageRepresentation(imageStrings: ["bookImage"])
    let magazineImageRepresentation = ImageRepresentation(imageStrings: ["magazineImage"])
    let rhythmicImageRepresentationAlphabets = ImageRepresentation(imageStrings: ["stateZeroImage", "stateOneImage"])
    let rhythmicImageRepresentationNumeric = ImageRepresentation(imageStrings: ["0", "1"])
    let titledItemImageRepresentation1 = ImageRepresentation(imageStrings: ["titledItem1"])
    let titledItemImageRepresentation2 = ImageRepresentation(imageStrings: ["titledItem2"])
    let statefulItemImageRepresentation1 = ImageRepresentation(imageStrings: ["statefulItem1"])
    let statefulItemImageRepresentation2 = ImageRepresentation(imageStrings: ["statefulItem2"])

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
                                  imageRepresentation: ImageRepresentation(imageStrings: ["circularImage"]))
        let wheel2 = StatefulItem(category: wheelCategory, stateIdentifier: 1,
                                  isInventoryItem: true, isOrderItem: false,
                                  imageRepresentation: ImageRepresentation(imageStrings: ["triangularImage"]))
        let expectedWheels = Set<[StatefulItem]>([[wheel1], [wheel2]])
        XCTAssertEqual(actualWheels, expectedWheels)
        
        // battery
        let batteryCategory = Category(name: "battery")
        let actualBatteries = actualResult[batteryCategory]!
        let battery1 = StatefulItem(category: batteryCategory, stateIdentifier: 0,
                                    isInventoryItem: true, isOrderItem: false,
                                    imageRepresentation: ImageRepresentation(imageStrings: ["AAImage"]))
        let battery2 = StatefulItem(category: batteryCategory, stateIdentifier: 1,
                                    isInventoryItem: true, isOrderItem: false,
                                    imageRepresentation: ImageRepresentation(imageStrings: ["AAAImage"]))
        let battery3 = StatefulItem(category: batteryCategory, stateIdentifier: 2,
                                    isInventoryItem: true, isOrderItem: false,
                                    imageRepresentation: ImageRepresentation(imageStrings: ["DImage"]))
        let battery4 = StatefulItem(category: batteryCategory, stateIdentifier: 3,
                                    isInventoryItem: true, isOrderItem: false,
                                    imageRepresentation: ImageRepresentation(imageStrings: ["PP3Image"]))
        let expectedBatteries = Set<[StatefulItem]>([[battery1], [battery2], [battery3], [battery4]])
        XCTAssertEqual(actualBatteries, expectedBatteries)
        
        // carBody
        let carBodyCategory = Category(name: "carBody")
        let actualCarBodies = actualResult[carBodyCategory]!
        let carBody1 = StatefulItem(category: carBodyCategory, stateIdentifier: 0,
                                    isInventoryItem: true, isOrderItem: false,
                                    imageRepresentation: ImageRepresentation(imageStrings: ["redImage"]))
        let carBody2 = StatefulItem(category: carBodyCategory, stateIdentifier: 1,
                                    isInventoryItem: true, isOrderItem: false,
                                    imageRepresentation: ImageRepresentation(imageStrings: ["blueImage"]))
        let carBody3 = StatefulItem(category: carBodyCategory, stateIdentifier: 2,
                                    isInventoryItem: true, isOrderItem: false,
                                    imageRepresentation: ImageRepresentation(imageStrings: ["yellowImage"]))
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
                               imageRepresentation: bookImageRepresentation)
        let book2 = TitledItem(name: "The book title is title is", category: bookCategory,
                               isInventoryItem: true, isOrderItem: true,
                               imageRepresentation: bookImageRepresentation)
        let book3 = TitledItem(name: "The book title", category: bookCategory,
                               isInventoryItem: true, isOrderItem: true,
                               imageRepresentation: bookImageRepresentation)
        let book4 = TitledItem(name: "Is the book title", category: bookCategory,
                               isInventoryItem: true, isOrderItem: true,
                               imageRepresentation: bookImageRepresentation)
        let expectedBooks = Set<[TitledItem]>([[book1, book2], [book3, book4]])
        XCTAssertEqual(actualBooks, expectedBooks)
        
        // magazines
        let magazineCategory = Category(name: "magazine")
        let actualMagazines = actualResult[magazineCategory]!
        let magazine1 = TitledItem(name: "By", category: magazineCategory,
                                   isInventoryItem: true, isOrderItem: true,
                                   imageRepresentation: magazineImageRepresentation)
        let magazine2 = TitledItem(name: "Buy", category: magazineCategory,
                                   isInventoryItem: true, isOrderItem: true,
                                   imageRepresentation: magazineImageRepresentation)
        let magazine3 = TitledItem(name: "Be", category: magazineCategory,
                                   isInventoryItem: true, isOrderItem: true,
                                   imageRepresentation: magazineImageRepresentation)
        let magazine4 = TitledItem(name: "Bee", category: magazineCategory,
                                   isInventoryItem: true, isOrderItem: true,
                                   imageRepresentation: magazineImageRepresentation)
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
                                  isOrderItem: true,
                                  imageRepresentation: rhythmicImageRepresentationAlphabets)
        let robot2 = RhythmicItem(unitDuration: 1, stateSequence: [lit, unlit, lit],
                                  category: robotCategory, isInventoryItem: true,
                                  isOrderItem: true,
                                  imageRepresentation: rhythmicImageRepresentationAlphabets)
        let robot3 = RhythmicItem(unitDuration: 2, stateSequence: [unlit, lit],
                                  category: robotCategory, isInventoryItem: true,
                                  isOrderItem: true,
                                  imageRepresentation: rhythmicImageRepresentationAlphabets)
        let robot4 = RhythmicItem(unitDuration: 2, stateSequence: [lit, unlit],
                                  category: robotCategory, isInventoryItem: true,
                                  isOrderItem: true,
                                  imageRepresentation: rhythmicImageRepresentationAlphabets)
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
                                     imageRepresentation: titledItemImageRepresentation1)
        let titledItem2 = TitledItem(name: "titledItem2", category: category2,
                                     isInventoryItem: true, isOrderItem: true,
                                     imageRepresentation: titledItemImageRepresentation2)
        let statefulItem1 = StatefulItem(category: category1, stateIdentifier: 0,
                                         isInventoryItem: true, isOrderItem: false,
                                         imageRepresentation: statefulItemImageRepresentation1)
        let statefulItem2 = StatefulItem(category: category1, stateIdentifier: 1,
                                         isInventoryItem: true, isOrderItem: false,
                                         imageRepresentation: statefulItemImageRepresentation2)
        let rhythmicItem1 = RhythmicItem(unitDuration: 1, stateSequence: [lit],
                                         category: category3, isInventoryItem: true,
                                         isOrderItem: true,
                                         imageRepresentation: rhythmicImageRepresentationNumeric)
        let rhythmicItem2 = RhythmicItem(unitDuration: 2, stateSequence: [unlit],
                                         category: category3, isInventoryItem: true,
                                         isOrderItem: true,
                                         imageRepresentation: rhythmicImageRepresentationNumeric)
        let rhythmicItem3 = RhythmicItem(unitDuration: 3, stateSequence: [unlit, lit],
                                         category: category3, isInventoryItem: true,
                                         isOrderItem: true,
                                         imageRepresentation: rhythmicImageRepresentationNumeric)
        
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
        
        let partsImageStrings = [category1: ImageRepresentation(imageStrings: ["toyCarCarBodyImage"]),
                                 category3: ImageRepresentation(imageStrings: ["toyCarBatteryImage"]),
                                 category2: ImageRepresentation(imageStrings: ["toyCarWheelImage"])]
        let imageRepresentation =
            AssembledItemImageRepresentation(mainImageStrings: ["toyCarImage"],
                                             partsImageStrings: partsImageStrings)
        let toyCar1 = AssembledItem(parts: [titledItem1, rhythmicItem1, statefulItem1],
                                    category: toyCarCategory,
                                    isInventoryItem: true, isOrderItem: true,
                                    imageRepresentation: imageRepresentation)
        let toyCar2 = AssembledItem(parts: [titledItem1, rhythmicItem1, statefulItem2],
                                    category: toyCarCategory,
                                    isInventoryItem: true, isOrderItem: true,
                                    imageRepresentation: imageRepresentation)
        let toyCar3 = AssembledItem(parts: [titledItem1, rhythmicItem2, statefulItem1],
                                    category: toyCarCategory,
                                    isInventoryItem: true, isOrderItem: true,
                                    imageRepresentation: imageRepresentation)
        let toyCar4 = AssembledItem(parts: [titledItem1, rhythmicItem2, statefulItem2],
                                    category: toyCarCategory,
                                    isInventoryItem: true, isOrderItem: true,
                                    imageRepresentation: imageRepresentation)
        let toyCar5 = AssembledItem(parts: [titledItem1, rhythmicItem3, statefulItem1],
                                    category: toyCarCategory,
                                    isInventoryItem: true, isOrderItem: true,
                                    imageRepresentation: imageRepresentation)
        let toyCar6 = AssembledItem(parts: [titledItem1, rhythmicItem3, statefulItem2],
                                    category: toyCarCategory,
                                    isInventoryItem: true, isOrderItem: true,
                                    imageRepresentation: imageRepresentation)
        let toyCar7 = AssembledItem(parts: [titledItem2, rhythmicItem1, statefulItem1],
                                    category: toyCarCategory,
                                    isInventoryItem: true, isOrderItem: true,
                                    imageRepresentation: imageRepresentation)
        let toyCar8 = AssembledItem(parts: [titledItem2, rhythmicItem1, statefulItem2],
                                    category: toyCarCategory,
                                    isInventoryItem: true, isOrderItem: true,
                                    imageRepresentation: imageRepresentation)
        let toyCar9 = AssembledItem(parts: [titledItem2, rhythmicItem2, statefulItem1],
                                    category: toyCarCategory,
                                    isInventoryItem: true, isOrderItem: true,
                                    imageRepresentation: imageRepresentation)
        let toyCar10 = AssembledItem(parts: [titledItem2, rhythmicItem2, statefulItem2],
                                     category: toyCarCategory,
                                     isInventoryItem: true, isOrderItem: true,
                                     imageRepresentation: imageRepresentation)
        let toyCar11 = AssembledItem(parts: [titledItem2, rhythmicItem3, statefulItem1],
                                     category: toyCarCategory,
                                     isInventoryItem: true, isOrderItem: true,
                                     imageRepresentation: imageRepresentation)
        let toyCar12 = AssembledItem(parts: [titledItem2, rhythmicItem3, statefulItem2],
                                     category: toyCarCategory,
                                     isInventoryItem: true, isOrderItem: true,
                                     imageRepresentation: imageRepresentation)
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
                                    imageRepresentation: titledItemImageRepresentation1)
        let statefulItem = StatefulItem(category: category1, stateIdentifier: 0,
                                        isInventoryItem: true, isOrderItem: false,
                                        imageRepresentation: statefulItemImageRepresentation1)
        let rhythmicItem1 = RhythmicItem(unitDuration: 1, stateSequence: [lit],
                                         category: category3, isInventoryItem: true,
                                         isOrderItem: true,
                                         imageRepresentation: rhythmicImageRepresentationNumeric)
        let rhythmicItem2 = RhythmicItem(unitDuration: 2, stateSequence: [unlit],
                                         category: category3, isInventoryItem: true,
                                         isOrderItem: true,
                                         imageRepresentation: rhythmicImageRepresentationNumeric)
        let book1 = TitledItem(name: "book1", category: category4,
                               isInventoryItem: true, isOrderItem: true,
                               imageRepresentation: bookImageRepresentation)
        let book2 = TitledItem(name: "book1", category: category4,
                               isInventoryItem: true, isOrderItem: true,
                               imageRepresentation: bookImageRepresentation)

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
        let partsImageStrings = [category1: ImageRepresentation(imageStrings: ["toyCarCarBodyImage"]),
                                 category3: ImageRepresentation(imageStrings: ["toyCarBatteryImage"]),
                                 category2: ImageRepresentation(imageStrings: ["toyCarWheelImage"])]
        let toyCarImageRepresentation =
            AssembledItemImageRepresentation(mainImageStrings: ["toyCarImage"],
                                             partsImageStrings: partsImageStrings)
        let toyCar1 = AssembledItem(parts: [titledItem, rhythmicItem1, statefulItem],
                                    category: toyCarCategory,
                                    isInventoryItem: true, isOrderItem: true,
                                    imageRepresentation: toyCarImageRepresentation)
        let toyCar2 = AssembledItem(parts: [titledItem, rhythmicItem2, statefulItem],
                                    category: toyCarCategory,
                                    isInventoryItem: true, isOrderItem: true,
                                    imageRepresentation: toyCarImageRepresentation)
        
        let partsImageStringsForToyCarGift =
            [toyCarCategory: ImageRepresentation(imageStrings: ["toyCarImage"]),
             category4: ImageRepresentation(imageStrings: ["bookImage"])]
        let toyCarGiftImageRepresentation =
            AssembledItemImageRepresentation(mainImageStrings: ["toyCarGiftImage"],
                                             partsImageStrings: partsImageStringsForToyCarGift)
        let toyCarGift1 = AssembledItem(parts: [toyCar1, book1], category: toyCarGiftCategory,
                                        isInventoryItem: false, isOrderItem: true,
                                        imageRepresentation: toyCarGiftImageRepresentation)
        let toyCarGift2 = AssembledItem(parts: [toyCar1, book2], category: toyCarGiftCategory,
                                        isInventoryItem: false, isOrderItem: true,
                                        imageRepresentation: toyCarGiftImageRepresentation)
        let toyCarGift3 = AssembledItem(parts: [toyCar2, book1], category: toyCarGiftCategory,
                                        isInventoryItem: false, isOrderItem: true,
                                        imageRepresentation: toyCarGiftImageRepresentation)
        let toyCarGift4 = AssembledItem(parts: [toyCar2, book2], category: toyCarGiftCategory,
                                        isInventoryItem: false, isOrderItem: true,
                                        imageRepresentation: toyCarGiftImageRepresentation)
        let expectedAssembledItems = Set<[AssembledItem]>([[toyCarGift1], [toyCarGift2], [toyCarGift3], [toyCarGift4]])
        
        XCTAssertEqual(actualAssembledItems, expectedAssembledItems)
        
    }
    
    func testPermuteParts() throws {
        let category1 = Category(name: "book")
        let category2 = Category(name: "wheel")

        let item1 = TitledItem(name: "1", category: category1,
                               isInventoryItem: true, isOrderItem: true,
                               imageRepresentation: imageRepresentationPlaceholder)
        let item2 = TitledItem(name: "2", category: category1,
                               isInventoryItem: true, isOrderItem: true,
                               imageRepresentation: imageRepresentationPlaceholder)
        let item3 = TitledItem(name: "3", category: category1,
                               isInventoryItem: true, isOrderItem: true,
                               imageRepresentation: imageRepresentationPlaceholder)
        let item4 = StatefulItem(category: category2, stateIdentifier: 0,
                                 isInventoryItem: true, isOrderItem: false,
                                 imageRepresentation: imageRepresentationPlaceholder)
        let item5 = StatefulItem(category: category2, stateIdentifier: 1,
                                 isInventoryItem: true, isOrderItem: false,
                                 imageRepresentation: imageRepresentationPlaceholder)

        let availableParts = [[item1, item2, item3], [item4, item5]]
        
        let result = ItemSpecificationsParser.permuteParts(availableParts: availableParts, currentIndex: 0)
        let expected = [[item1, item4], [item1, item5], [item2, item4], [item2, item5],
                        [item3, item4], [item3, item5]]
        XCTAssertEqual(result, expected)
    }

    func testGetStateIdentifierMappings() throws {
        let itemsDict = try TestItemSpecificationsParser.getPlist(from: testGameConfigFileName)
        let actualMappings =
            ItemSpecificationsParser.getAssembledItemToImageRepresentationMapping(dict: itemsDict)
        
        let toyCarCategory = Category(name: "toyCar")
        let toyCarGiftCategory = Category(name: "toyCarGift")
        let wheelCategory = Category(name: "wheel")
        let batteryCategory = Category(name: "battery")
        let carBodyCategory = Category(name: "carBody")
        let bookCategory = Category(name: "book")
        let toyCarPartsImageStrings = [wheelCategory: ImageRepresentation(imageStrings: ["circle",
                                                                                         "triangle"]),
                                       batteryCategory: ImageRepresentation(imageStrings: ["AA",
                                                                                           "AAA",
                                                                                           "D", "PP3"]),
                                       carBodyCategory: ImageRepresentation(imageStrings:
                                        ["redCarBodyImage",
                                         "blueCarBodyImage",
                                         "yellowCarBodyImage"])]

        let toyCarImage = ImageRepresentation(imageStrings: ["toyCarImage"])
        let bookImage = ImageRepresentation(imageStrings: ["bookImage"])
        let toyCarGiftPartsImageStrings = [toyCarCategory: toyCarImage,
                                           bookCategory: bookImage]
        let expectedMappings = [toyCarCategory:
            AssembledItemImageRepresentation(mainImageStrings: ["toyCarImage"],
                                             partsImageStrings: toyCarPartsImageStrings),
                                toyCarGiftCategory:
            AssembledItemImageRepresentation(mainImageStrings: ["toyCarGiftImage"],
                                             partsImageStrings: toyCarGiftPartsImageStrings)]

        XCTAssertEqual(Set(actualMappings.keys), Set(expectedMappings.keys))
        for key in actualMappings.keys {
            XCTAssertEqual(actualMappings[key], expectedMappings[key])
        }
    }
}
