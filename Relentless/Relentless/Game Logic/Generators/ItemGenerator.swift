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
    let numOfGroupsPerCategory: Int
    let itemSpecifications: ItemSpecifications

    var availableGroups: [Category: Set<[Item]>] {
        itemSpecifications.availableGroupsOfItems
    }

    init(numberOfPlayers: Int, numOfGroupsPerCategory: Int,
         itemSpecifications: ItemSpecifications) {
        self.numberOfPlayers = numberOfPlayers
        self.numOfGroupsPerCategory = numOfGroupsPerCategory
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
        // Should not go into infinite loop as category generator checks that there are at least
        // as many inventory items as number of players
        var uniqueInventoryItemsCount = items.count
        while uniqueInventoryItemsCount < numberOfPlayers {
            for category in categories {
                guard let availableItemsForCategory = availableGroups[category] else {
                    continue
                }
                let generatedItems = generateItems(for: category,
                                                   numberToGenerate: numOfGroupsPerCategory,
                                                   availableGroups: Array(availableItemsForCategory))
                items = items.union(generatedItems)
            }
            uniqueInventoryItemsCount = getUniqueInventoryItems(items: items).count
        }
        return items
    }

    /// Generates items for specified category
    private func generateItems(for category: Category, numberToGenerate: Int, availableGroups: [[Item]]) -> Set<Item> {
        var groups = Set<[Item]>()
        var numberOfGroupsNeeded = numberToGenerate
        // exclude those that have non-order items
        let eligibleGroups = availableGroups.filter { $0.allSatisfy { $0.isOrderItem } }
        if eligibleGroups.count < numberToGenerate {
            numberOfGroupsNeeded = eligibleGroups.count
        }
        while groups.count < numberOfGroupsNeeded {
            guard let selectedGroup = getRandom(from: eligibleGroups) as? [Item] else {
                continue
            }
            groups.insert(selectedGroup)
        }
        return Set(groups.flatMap { $0.self })
    }

    private func getRandom(from list: [Any]) -> Any {
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
