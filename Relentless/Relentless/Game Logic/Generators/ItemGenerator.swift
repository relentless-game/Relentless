//
//  ItemGenerator.swift
//  Relentless
//
//  Created by Yi Wai Chow on 15/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class ItemGenerator: GameItemGenerator {
    let numberOfPlayers: Int
    let difficultyLevel: Float
    let numOfPairsPerCategory: Int
    let itemSpecifications: ItemSpecifications

    var availableItems: [Category: Set<Item>] {
        itemSpecifications.availableItems
    }

    init(numberOfPlayers: Int, difficultyLevel: Float,
         numOfPairsPerCategory: Int, itemSpecifications: ItemSpecifications) {
        self.numberOfPlayers = numberOfPlayers
        self.difficultyLevel = difficultyLevel
        self.numOfPairsPerCategory = numOfPairsPerCategory
        self.itemSpecifications = itemSpecifications
    }

    /// Generates items based on the specified categories
    func generate(categories: [Category]) -> ([Item], [Item]) {
        let orderItems = generateOrderItems(categories: categories)
        let inventoryItems = getUniqueInventoryItems(items: orderItems)
        return (Array(inventoryItems), Array(orderItems))
    }

    /// Generates order items while ensuring that every player has at least one inventory item
    private func generateOrderItems(categories: [Category]) -> Set<Item> {
        var items = Set<Item>()
        var uniqueInventoryItemsCount = items.count
        while uniqueInventoryItemsCount < numberOfPlayers {
            for category in categories {
                guard let availableItemsForCategory = availableItems[category] else {
                    continue
                }
                let generatedItems = generateItems(for: category,
                                                   numberToGenerate: numOfPairsPerCategory,
                                                   availableItems: Array(availableItemsForCategory))
                items = items.union(generatedItems)
            }
            uniqueInventoryItemsCount = getUniqueInventoryItems(items: items).count
        }
        return items
    }

    /// Generates items for specified category
    private func generateItems(for category: Category, numberToGenerate: Int, availableItems: [Item]) -> Set<Item> {
        var items = Set<Item>()
        var numberOfItemsNeeded = numberToGenerate
        if availableItems.count < numberToGenerate {
            numberOfItemsNeeded = availableItems.count
        }
        while items.count < numberOfItemsNeeded {
            let selectedItem = getRandomItem(from: availableItems)
            if !selectedItem.isOrderItem {
                continue
            }
            items.insert(selectedItem)
        }
        return items
    }

    private func getRandomItem(from list: [Item]) -> Item {
        let indexRange = 0...(list.count - 1)
        let randomIndex = Int.random(in: indexRange)
        return list[randomIndex]
    }

    private func getUniqueInventoryItems(items: Set<Item>) -> Set<Item> {
        let inventoryItems = items.filter { $0.isInventoryItem }
        // extract parts of nonInventoryItems that are AssembledItems
        let nonInventoryAssembledItems = items.filter { !$0.isInventoryItem }.compactMap { $0 as? AssembledItem }
        let partsThatAreInventoryItems = nonInventoryAssembledItems
            .flatMap { $0.unsortedParts }
            .filter { $0.isInventoryItem }
        var allInventoryItems = [Item]()
        allInventoryItems.append(contentsOf: inventoryItems)
        allInventoryItems.append(contentsOf: partsThatAreInventoryItems)
        return Set(allInventoryItems)
    }

}
