//
//  CategoryGenerator.swift
//  Relentless
//
//  Created by Yi Wai Chow on 17/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// Generates categories by choosing from the currently available categories
class CategoryGenerator: GameCategoryGenerator {

    var numberOfPlayers: Int
    var difficultyLevel: Double
    var numOfCategories: Int
    let categoryToGroupsMapping: [Category: Set<[Item]>]
    var allCategories: [Category] {
        Array(categoryToGroupsMapping.keys)
    }

    init(numberOfPlayers: Int, difficultyLevel: Double, numOfCategories: Int,
         categoryToGroupsMapping: [Category: Set<[Item]>]) {
        self.numberOfPlayers = numberOfPlayers
        self.difficultyLevel = difficultyLevel
        self.numOfCategories = numOfCategories
        self.categoryToGroupsMapping = categoryToGroupsMapping
    }

    func generateCategories() -> [Category] {
        //let allCategories = Category.allCases

        // if number of categories is less than required, just return all available categories
        if allCategories.count < numOfCategories {
            return allCategories
        }

        let categoriesWithOrders = allCategories.filter { !checkHasNoOrderItems(in: $0) }
        assert(checkHasEnoughInventoryItems(categories: Set(categoriesWithOrders)),
               "Not enough inventory items... Designer should add more items")

        let generationRange = 0...categoriesWithOrders.count - 1
        var categories = Set<Category>()

        if categoriesWithOrders.count < numOfCategories {
            numOfCategories = categoriesWithOrders.count
        }

        // choose unique random categories
        while categories.count < numOfCategories {
            let index = Int.random(in: generationRange)
            categories.insert(categoriesWithOrders[index])
        }

        return Array(categories)
    }

    /// Considered enough as long as there are at least as many inventory items as the number of players
    private func checkHasEnoughInventoryItems(categories: Set<Category>) -> Bool {
        let itemsInCategories = categories.compactMap { categoryToGroupsMapping[$0] }.reduce(Set<Item>()) { result, group in
            result.union(group.flatMap { $0 })
        }
        return itemsInCategories.count >= numberOfPlayers
    }

    private func checkHasNoOrderItems(in category: Category) -> Bool {
        guard let groupsInCategory = categoryToGroupsMapping[category] else {
            return true
        }
        let itemsInCategory = Array(groupsInCategory).flatMap { $0 }
        return !itemsInCategory.contains(where: { $0.isOrderItem })
    }
}
