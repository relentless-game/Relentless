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
    var difficultyLevel: Float // ranges from 0 (easiest) to 1 (most difficult)
    var numOfCategories: Int
    let allCategories: [Category]

    init(numberOfPlayers: Int, difficultyLevel: Float, numOfCategories: Int, allCategories: [Category]) {
        self.numberOfPlayers = numberOfPlayers
        self.difficultyLevel = difficultyLevel
        self.numOfCategories = numOfCategories
        self.allCategories = allCategories
    }

    func generateCategories() -> [Category] {
        //let allCategories = Category.allCases

        // if number of categories is less than required, just return all available categories
        if allCategories.count < numOfCategories {
            return allCategories
        }

        let generationRange = 0...allCategories.count - 1
        var categories = Set<Category>()

        // choose unique random categories
        while categories.count < numOfCategories {
            let index = Int.random(in: generationRange)
            categories.insert(allCategories[index])
        }
        
        return Array(categories)
    }

}
