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

    var defaultNumOfCats: Int = 1 // per player

    init(numberOfPlayers: Int, difficultyLevel: Float) {
        self.numberOfPlayers = numberOfPlayers
        self.difficultyLevel = difficultyLevel
    }

    func generateCategories() -> [Category] {
        let numberToGenerate = numberOfPlayers * (defaultNumOfCats + Int(difficultyLevel *
            Float(defaultNumOfCats)))
        let allCategories = Category.AllCases.init()

        // if number of categories is less than required, just return all available categories
        if allCategories.count < numberToGenerate {
            return allCategories
        }

        let generationRange = 0...numberToGenerate
        var categories = Set<Category>()

        // choose unique random categories
        while categories.count < numberToGenerate {
            let index = Int.random(in: generationRange)
            categories.insert(allCategories[index])
        }
        return Array(categories)
    }

}
