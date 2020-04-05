//
//  GameHostParameters.swift
//  Relentless
//
//  Created by Yi Wai Chow on 27/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// Represents the parameters for the game that is only used by the host in item and order generation and allocation.
class GameHostParameters: GameParameters {

    static var timeForEachItem: Int = 70

    /// For item generation
    var numOfCategories: Int {
        let difficultyFraction = difficultyLevel / GameParameters.difficultyRange.upperBound
        let numberOfCategories = Category.allCases.count
        return Int((Float(numberOfCategories) * difficultyFraction).rounded(.up))
    }
    var numOfPairsPerCategory: Int {
        Int((difficultyLevel / 2).rounded(.up))
    }

    /// For order generation
    var maxNumOfItemsPerOrder: Int {
        Int((difficultyLevel / 2).rounded(.up))
    }

    /// For order allocation
    var numOfOrdersPerPlayer: Int {
        Int((difficultyLevel / 2).rounded(.up))
    }
    // Should be between 0 and 1
    var probabilityOfSelectingOwnItem: Float {
        let probability = 1 / (difficultyLevel + 1)
        assert(probability >= 0 && probability <= 1)
        return probability
    }

    /// For package items limit
    // Should be between 0 and 1
    var probabilityOfHavingPackageLimit: Float {
        difficultyLevel / 50
    }

    static func probabilityOfSelectingAssembledItem(numberOfPlayers: Int) -> Float {
        1 / Float(numberOfPlayers)
    }

    /// For random events
    // Should be between 0 and 1
    var probabilityOfEvent: Float {
        difficultyLevel / 50
    }

}
