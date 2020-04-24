//
//  ItemGeneratorTests.swift
//  RelentlessTests
//
//  Created by Chow Yi Yin on 20/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class ItemGeneratorTests: XCTestCase {
    typealias Cat = Relentless.Category
    var itemTypeToCategoryMappingForTest = [ItemType: [Cat]]()
    var availableGroupsOfItems = [Cat: Set<[Item]>]()
    var assembledItemCategories = [Cat]()
    var itemSpecifications: ItemSpecifications {
        let itemIdentifierMappings = [Cat: [Int: String]]() // not needed for this test
        let partToAssembledItemCategoryMapping = [[Cat]: Cat]() // not needed for this test
        return ItemSpecifications(availableGroupsOfItems: availableGroupsOfItems,
                                  itemIdentifierMappings: itemIdentifierMappings,
                                  partsToAssembledItemCategoryMapping: partToAssembledItemCategoryMapping)
    }
    var categories: [Cat] {
        Array(itemSpecifications.availableGroupsOfItems.keys)
    }

    override func setUp() {
        super.setUp()
        initialiseTestItems()
    }

    override func tearDown() {
        super.tearDown()
        itemTypeToCategoryMappingForTest = [ItemType: [Cat]]()
        availableGroupsOfItems = [Cat: Set<[Item]>]()
        assembledItemCategories = [Cat]()
    }

    func testGenerate_hasSufficientItemsForRequiredSpecification() {
        let numberOfPlayers = 3
        let numOfGroupsPerCategory = 2
        let generator = ItemGenerator(numberOfPlayers: numberOfPlayers,
                                      numOfGroupsPerCategory: numOfGroupsPerCategory,
                                      itemSpecifications: itemSpecifications)
        let items = generator.generate(categories: categories)
        let inventoryItems = items.0
        let orderItems = items.1
        XCTAssertTrue(inventoryItems.count >= numberOfPlayers)
        XCTAssertTrue(orderItems.allSatisfy { $0.isOrderItem })
        XCTAssertTrue(inventoryItems.allSatisfy { $0.isInventoryItem })
        XCTAssertFalse(orderItems.isEmpty)
        XCTAssertFalse(inventoryItems.isEmpty)
    }

    func testGenerate_hasInSufficientItemsForRequiredSpecification_noInfiniteLoop() {
        let numberOfPlayers = 3
        let numOfGroupsPerCategory = 5
        let generator = ItemGenerator(numberOfPlayers: numberOfPlayers,
                                      numOfGroupsPerCategory: numOfGroupsPerCategory,
                                      itemSpecifications: itemSpecifications)
        let items = generator.generate(categories: categories)
        let inventoryItems = items.0
        let orderItems = items.1
        XCTAssertTrue(inventoryItems.count >= numberOfPlayers)
        XCTAssertTrue(orderItems.allSatisfy { $0.isOrderItem })
        XCTAssertTrue(inventoryItems.allSatisfy { $0.isInventoryItem })
    }

    func testGenerate_assembledItemsCanBeAssembled() {
        for numOfPlayers in 3...4 {
            for numOfGroupsPerCategory in 1...5 {
                testGenerate_assembledItemsCanBeAssembled(numOfPlayers: numOfPlayers,
                                                          numOfGroupsPerCategory: numOfGroupsPerCategory)
            }
        }
    }

    private func testGenerate_assembledItemsCanBeAssembled(numOfPlayers: Int, numOfGroupsPerCategory: Int) {
        let generator = ItemGenerator(numberOfPlayers: numOfPlayers,
                                      numOfGroupsPerCategory: numOfGroupsPerCategory,
                                      itemSpecifications: itemSpecifications)
        guard let assembledItemCategories = itemTypeToCategoryMappingForTest[ItemType.assembledItem] else {
            XCTFail("Something went wrong with set up...")
            return

        }
        let items = generator.generate(categories: assembledItemCategories)
        let inventoryItems = items.0
        let orderItems = items.1
        for item in orderItems {
            guard let assembledItem = item as? AssembledItem else {
                XCTFail("Should be assembled item...")
                continue
            }
            let parts = assembledItem.parts
            XCTAssertTrue(parts.allSatisfy { inventoryItems.contains($0) })
        }
    }
}

extension ItemGeneratorTests {
    internal func initialiseTestItems() {
        var items = [Cat: Set<[Item]>]()
        // Books are all inventory and order items
        let bookCategory = Category(name: "book")
        let books = getTitledItems(category: bookCategory)
        let setOfBooks = Set(books)
        items[bookCategory] = setOfBooks
        itemTypeToCategoryMappingForTest[ItemType.titledItem] = [bookCategory]

        // Wheels are all inventory items but not order items
        let wheelCategory = Category(name: "wheel")
        let wheels = getStatefulItemsAllNotOrder(category: wheelCategory)
        let setOfWheels = Set(wheels)
        items[wheelCategory] = setOfWheels
        itemTypeToCategoryMappingForTest[ItemType.statefulItem] = [wheelCategory]

        // Some batteries are order items and some are not. All are inventory items
        let batteryCategory = Category(name: "battery")
        let batteries = getStatefulItemsSomeOrder(category: batteryCategory)
        let setOfBatteries = Set(batteries)
        items[batteryCategory] = setOfBatteries
        // Toy cars are all order items but not inventory items. toyCar parts are all only inventoryItems
        let toyCarCategory = Category(name: "toyCar")
        let partsImageStrings = [Cat: String]()
        let toyCars = getAssembledItems(category: toyCarCategory, parts: [wheels[0], batteries[0]],
                                        partsImageStrings: partsImageStrings)
        let setOfCars = Set(toyCars)
        items[toyCarCategory] = setOfCars

        availableGroupsOfItems = items
        itemTypeToCategoryMappingForTest[ItemType.assembledItem] = [toyCarCategory]
    }

    internal func getTitledItems(category: Cat) -> [[Item]] {
        [[TitledItem(name: "t1", category: category, isInventoryItem: true,
                     isOrderItem: true, imageString: ""),
          TitledItem(name: "t2", category: category, isInventoryItem: true,
                     isOrderItem: true, imageString: "")],
         [TitledItem(name: "t3", category: category,
                     isInventoryItem: true, isOrderItem: true, imageString: ""),
          TitledItem(name: "t4", category: category,
                     isInventoryItem: true, isOrderItem: true, imageString: "")]]
    }

    internal func getStatefulItemsAllNotOrder(category: Cat) -> [[Item]] {
        [[StatefulItem(category: category, stateIdentifier: 1,
                       isInventoryItem: true, isOrderItem: false, imageString: ""),
          StatefulItem(category: category, stateIdentifier: 2,
                       isInventoryItem: true, isOrderItem: false, imageString: "")],
         [StatefulItem(category: category, stateIdentifier: 3,
                       isInventoryItem: true, isOrderItem: false, imageString: ""),
          StatefulItem(category: category, stateIdentifier: 4,
                       isInventoryItem: true, isOrderItem: false, imageString: "")]]
    }

    internal func getStatefulItemsSomeOrder(category: Cat) -> [[Item]] {
        [[StatefulItem(category: category, stateIdentifier: 1,
                       isInventoryItem: true, isOrderItem: true, imageString: ""),
          StatefulItem(category: category, stateIdentifier: 2,
                       isInventoryItem: true, isOrderItem: true, imageString: "")],
         [StatefulItem(category: category, stateIdentifier: 3,
                       isInventoryItem: true, isOrderItem: false, imageString: ""),
          StatefulItem(category: category, stateIdentifier: 4,
                       isInventoryItem: true, isOrderItem: false, imageString: "")],
         [StatefulItem(category: category, stateIdentifier: 5,
                       isInventoryItem: true, isOrderItem: true, imageString: ""),
          StatefulItem(category: category, stateIdentifier: 6,
                       isInventoryItem: true, isOrderItem: true, imageString: "")]]
    }

    internal func getAssembledItems(category: Cat, parts: [[Item]],
                                    partsImageStrings: [Cat: String]) -> [[Item]] {
        var items = [[Item]]()
        let maxCounter = parts.map { $0.count }.reduce(100, { x, y in
            min(x, y)
        })
        for counter in 0..<maxCounter {
            let parts = parts.map { $0[counter] }
            items.append([AssembledItem(parts: parts, category: category, isInventoryItem: false,
                                        isOrderItem: true, mainImageString: "",
                                        partsImageStrings: partsImageStrings)])
        }
        return items
    }
}
