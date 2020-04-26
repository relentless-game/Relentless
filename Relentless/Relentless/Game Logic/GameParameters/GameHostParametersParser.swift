//
//  GameHostParametersParser.swift
//  Relentless
//
//  Created by Yi Wai Chow on 12/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
import Firebase

/// This represents a parser that parses configuration of game parameters stored remotely
/// or locally into a `GameParameters` object for the host player to use.
class GameHostParametersParser: GameParametersParser {
    typealias IR = ClosedRange<Int>

    override func parse() -> GameHostParameters? {
        let gameHostParameters = GameHostParameters()

        guard parseNumbers(gameHostParameters: gameHostParameters) else {
            return nil
        }

        guard parseStrings(gameHostParameters: gameHostParameters) else {
            return nil
        }

        return gameHostParameters
    }

    internal func parseNumbers(gameHostParameters: GameHostParameters) -> Bool {
        guard super.parseNumbers(gameParameters: gameHostParameters) else {
            return false
        }
        guard let numOfPlayersRange: IR = parseNumbersToRange(minKey: ConfigKeys.minNumOfPlayers,
                                                              maxKey: ConfigKeys.maxNumOfPlayers)
            else {
                return false
        }
        gameHostParameters.numOfPlayersRange = numOfPlayersRange
        return true
    }

    internal func parseStrings(gameHostParameters: GameHostParameters) -> Bool {
        guard super.parseStrings(gameParameters: gameHostParameters) else {
            return false
        }

        guard let timeForEachItemExpression: I = parseStringExpression(key: ConfigKeys.timeForEachItem),
            let numOfCategoriesExpression: I = parseStringExpression(key: ConfigKeys.numOfCategories),
            let numOfGroupsPerCategoryExpression: I = parseStringExpression(key: ConfigKeys.numOfGroupsPerCategory),
            let maxNumOfItemsPerOrderExpression: I = parseStringExpression(key: ConfigKeys.maxNumOfItemsPerOrder),
            let numOfOrdersPerPlayerExpression: I = parseStringExpression(key: ConfigKeys.numOfOrdersPerPlayer),
            let probOfSelectingOwnItemExpression: D = parseStringExpression(key: ConfigKeys.probOfSelectingOwnItem),
            let probOfHavingPackageLimitExpression: D = parseStringExpression(key: ConfigKeys.probOfHavingPackageLimit) else {
                return false
        }

        gameHostParameters.timeForEachItemExpression = timeForEachItemExpression
        gameHostParameters.numOfCategoriesExpression = numOfCategoriesExpression
        gameHostParameters.numOfGroupsPerCategoryExpression = numOfGroupsPerCategoryExpression
        gameHostParameters.maxNumOfItemsPerOrderExpression = maxNumOfItemsPerOrderExpression
        gameHostParameters.numOfOrdersPerPlayerExpression = numOfOrdersPerPlayerExpression
        gameHostParameters.probOfSelectingOwnItemExpression = probOfSelectingOwnItemExpression
        gameHostParameters.probOfHavingPackageLimitExpression = probOfHavingPackageLimitExpression
        return true
    }
}
