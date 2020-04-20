//
//  GameHostParametersParser.swift
//  Relentless
//
//  Created by Yi Wai Chow on 12/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
import Firebase

class GameHostParametersParser: GameParametersParser {

    let timeForEachItemConfigKey = "timeForEachItem"
    let numOfCategoriesConfigKey = "numOfCategories"
    let numOfGroupsPerCategoryConfigKey = "numOfGroupsPerCategory"
    let maxNumOfItemsPerOrderConfigKey = "maxNumOfItemsPerOrder"
    let numOfOrdersPerPlayerConfigKey = "numOfOrdersPerPlayer"
    let probOfSelectingOwnItemConfigKey = "probOfSelectingOwnItem"
    let probOfHavingPackageLimitConfigKey = "probOfHavingPackageLimit"
    let probOfSelectingAssembledItemConfigKey = "probOfSelectingAssembledItem"
    let probOfEventConfigKey = "probOfEvent"

    override func parse() -> GameHostParameters? {
        let gameHostParameters = GameHostParameters()

        guard parseNumbers() else {
            return nil
        }

        guard parseStrings(gameHostParameters: gameHostParameters) else {
            return nil
        }

        return gameHostParameters
    }

    internal func parseStrings(gameHostParameters: GameHostParameters) -> Bool {
        guard super.parseStrings(gameParameters: gameHostParameters) else {
            return false
        }

        guard let timeForEachItemExpression: I = parseStringExpression(key: timeForEachItemConfigKey),
            let numOfCategoriesExpression: I = parseStringExpression(key: numOfCategoriesConfigKey),
            let numOfGroupsPerCategoryExpression: I = parseStringExpression(key: numOfGroupsPerCategoryConfigKey),
            let maxNumOfItemsPerOrderExpression: I = parseStringExpression(key: maxNumOfItemsPerOrderConfigKey),
            let numOfOrdersPerPlayerExpression: I = parseStringExpression(key: numOfOrdersPerPlayerConfigKey),
            let probOfSelectingOwnItemExpression: D = parseStringExpression(key: probOfSelectingOwnItemConfigKey),
            let probOfHavingPackageLimitExpression: D = parseStringExpression(key: probOfHavingPackageLimitConfigKey),
            let probOfSelectingAssembledItemExpression: D = parseStringExpression(key:
                probOfSelectingAssembledItemConfigKey),
            let probOfEventExpression: D = parseStringExpression(key: probOfEventConfigKey) else {
                return false
        }

        gameHostParameters.timeForEachItemExpression = timeForEachItemExpression
        gameHostParameters.numOfCategoriesExpression = numOfCategoriesExpression
        gameHostParameters.numOfGroupsPerCategoryExpression = numOfGroupsPerCategoryExpression
        gameHostParameters.maxNumOfItemsPerOrderExpression = maxNumOfItemsPerOrderExpression
        gameHostParameters.numOfOrdersPerPlayerExpression = numOfOrdersPerPlayerExpression
        gameHostParameters.probOfSelectingOwnItemExpression = probOfSelectingOwnItemExpression
        gameHostParameters.probOfHavingPackageLimitExpression = probOfHavingPackageLimitExpression
        gameHostParameters.probOfSelectingAssembledItemExpression = probOfSelectingAssembledItemExpression
        gameHostParameters.probOfEventExpression = probOfEventExpression
        return true
    }
}
