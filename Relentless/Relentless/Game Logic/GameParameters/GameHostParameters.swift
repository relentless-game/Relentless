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

    /// The following are closures that take in parameters (currently only difficulty level)
    /// They are used to compute the actual variable values
    internal var timeForEachItemExpression: I?
    internal var numOfCategoriesExpression: I?
    internal var numOfGroupsPerCategoryExpression: I?
    internal var maxNumOfItemsPerOrderExpression: I?
    internal var numOfOrdersPerPlayerExpression: I?
    internal var probOfSelectingOwnItemExpression: F?
    internal var probOfHavingPackageLimitExpression: F?
    internal var probOfSelectingAssembledItemExpression: F?
    internal var probOfEventExpression: F?

    /// The following properties are computed based on the closures above and take in a dictionary
    /// that specifies the variable values in the closure expressions
    var timeForEachItem: Int {
        let defaultValue = 70
        return timeForEachItemExpression?(varDict) ?? defaultValue
    }

    /// For item generation
    var numOfCategories: Int {
        let difficultyFraction = difficultyLevel / GameParameters.difficultyRange.upperBound
        // TODO: fix this. put 5 here as a place holder for now
        let numberOfCategories = 5 //Category.allCases.count
        let defaultValue = Int((Float(numberOfCategories) * difficultyFraction).rounded(.up))
        return numOfCategoriesExpression?(varDict) ?? defaultValue
    }
    var numOfGroupsPerCategory: Int {
        let defaultValue = Int((difficultyLevel / 2).rounded(.up))
        return numOfGroupsPerCategoryExpression?(varDict) ?? defaultValue
    }

    /// For order generation
    var maxNumOfItemsPerOrder: Int {
        let defaultValue = Int((difficultyLevel / 2).rounded(.up))
        return maxNumOfItemsPerOrderExpression?(varDict) ?? defaultValue
    }

    /// For order allocation
    var numOfOrdersPerPlayer: Int {
        let defaultValue = Int((difficultyLevel / 2).rounded(.up))
        return numOfOrdersPerPlayerExpression?(varDict) ?? defaultValue
    }
    // Should be between 0 and 1
    var probOfSelectingOwnItem: Float {
        let probability = 1 / (difficultyLevel + 1)
        assert(probability >= 0 && probability <= 1)
        let defaultValue = probability
        return probOfSelectingOwnItemExpression?(varDict) ?? defaultValue
    }

    /// For package items limit
    // Should be between 0 and 1
    var probOfHavingPackageLimit: Float {
        let defaultValue = difficultyLevel / 50
        return probOfHavingPackageLimitExpression?(varDict) ?? defaultValue
    }

    /// For random events
    // Should be between 0 and 1
    var probOfEvent: Float {
        let defaultValue = difficultyLevel / 50
        return probOfEventExpression?(varDict) ?? defaultValue
    }

    func probOfSelectingAssembledItem(numberOfPlayers: Int) -> Float {
        let defaultValue = 1 / Float(numberOfPlayers)
        return probOfSelectingAssembledItemExpression?(varDict) ?? defaultValue
    }

}
