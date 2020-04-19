//
//  GameParametersParser.swift
//  Relentless
//
//  Created by Yi Wai Chow on 11/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
import Firebase

class GameParametersParser {
    typealias I = ([String: Float]) -> Int?
    typealias F = ([String: Float]) -> Float?
    typealias IR = ClosedRange<Int>
    typealias FR = ClosedRange<Float>

    let remoteConfig: RemoteConfig

    // keys for number values
    let minNumOfPlayersConfigKey = "minNumOfPlayers"
    let maxNumOfPlayersConfigKey = "maxNumOfPlayers"
    let minDifficultyLevelConfigKey = "minDifficultyLevel"
    let maxDifficultyLevelConfigKey = "maxDifficultyLevel"
    let minSatisfactionConfigKey = "minSatisfaction"
    let maxSatisfactionConfigKey = "maxSatisfaction"

    // keys for string expressions
    let difficultyChangeConfigKey = "difficultyChange"
    let roundTimeConfigKey = "roundTime"
    let dailyExpenseConfigKey = "dailyExpense"
    let correctPackageSatisfactionChangeConfigKey = "correctPackageSatisfactionChange"
    let wrongPackageSatisfactionChangeConfigKey = "wrongPackageSatisfactionChange"
    let numOfHousesConfigKey = "numOfHouses"
    let minHouseSatisfactionFactorConfigKey = "minHouseSatisfactionFactor"
    let maxHouseSatisfactionFactorConfigKey = "maxHouseSatisfactionFactor"
    let satisfactionToMoneyTranslationConfigKey = "satisfactionToMoneyTranslation"
    let satisfactionRunOutPenaltyConfigKey = "satisfactionRunOutPenalty"
    let satisfactionUnitDecreaseConfigKey = "satisfactionUnitDecrease"

    init(remoteConfig: RemoteConfig) {
        self.remoteConfig = remoteConfig
    }

    func parse() -> GameParameters? {
        let gameParameters = GameParameters()

        guard parseNumbers() else {
            return nil
        }

        guard parseStrings(gameParameters: gameParameters) else {
            return nil
        }

        return gameParameters
    }

    internal func parseNumbers() -> Bool {
        guard let numOfPlayersRange: IR = parseNumbersToRange(minKey: minNumOfPlayersConfigKey,
                                                              maxKey: maxNumOfPlayersConfigKey),
            let difficultyRange: FR = parseNumbersToRange(minKey: minDifficultyLevelConfigKey,
                                                          maxKey: maxDifficultyLevelConfigKey),
            let satisfactionRange: FR = parseNumbersToRange(minKey: minSatisfactionConfigKey,
                                                            maxKey: maxSatisfactionConfigKey)
            else {
                return false
        }
        GameParameters.numOfPlayersRange = numOfPlayersRange
        GameParameters.difficultyRange = difficultyRange
        GameParameters.satisfactionRange = satisfactionRange
        return true
    }

    internal func parseStrings(gameParameters: GameParameters) -> Bool {
        guard let numOfHouses: I = parseStringExpression(key: numOfHousesConfigKey),
            let difficultyChange: F = parseStringExpression(key: difficultyChangeConfigKey),
            let roundTime: I = parseStringExpression(key: roundTimeConfigKey),
            let dailyExpense: I = parseStringExpression(key: dailyExpenseConfigKey),
            let correctPackageSatisfactionChange: F = parseStringExpression(key:
                correctPackageSatisfactionChangeConfigKey),
            let wrongPackageSatisfactionChange: F = parseStringExpression(key: wrongPackageSatisfactionChangeConfigKey),
            let minHouseSatisfactionFactor: F = parseStringExpression(key: minHouseSatisfactionFactorConfigKey),
            let maxHouseSatisfactionFactor: F = parseStringExpression(key: maxHouseSatisfactionFactorConfigKey),
            let satisfactionToMoneyTranslation: I = parseStringExpression(key: satisfactionToMoneyTranslationConfigKey),
            let satisfactionRunOutPenalty: F = parseStringExpression(key: satisfactionRunOutPenaltyConfigKey),
            let satisfactionUnitDecrease: F = parseStringExpression(key: satisfactionUnitDecreaseConfigKey)
            else {
                return false
        }
        gameParameters.numOfHousesExpression = numOfHouses
        gameParameters.difficultyChangeExpression = difficultyChange
        gameParameters.roundTimeExpression = roundTime
        gameParameters.dailyExpenseExpression = dailyExpense
        gameParameters.correctPackageSatisfactionChangeExpression = correctPackageSatisfactionChange
        gameParameters.wrongPackageSatisfactionChangeExpression = wrongPackageSatisfactionChange
        gameParameters.minHouseSatisfactionFactorExpression = minHouseSatisfactionFactor
        gameParameters.maxHouseSatisfactionFactorExpression = maxHouseSatisfactionFactor
        gameParameters.satisfactionToMoneyTranslationExpression = satisfactionToMoneyTranslation
        gameParameters.satisfactionRunOutPenaltyExpression = satisfactionRunOutPenalty
        gameParameters.satisfactionUnitDecreaseExpression = satisfactionUnitDecrease
        return true
    }

    internal func parseNumbersToRange<T>(minKey: String, maxKey: String) -> ClosedRange<T>? {
        guard let minValue = remoteConfig[minKey].numberValue as? T else {
            return nil
        }
        guard let maxValue = remoteConfig[maxKey].numberValue as? T else {
            return nil
        }
        return minValue...maxValue
    }

    internal func parseStringExpression<T>(key: String) -> (([String: Float]) -> T?)? {
        guard let raw = remoteConfig[key].stringValue else {
            return nil
        }
        let expression = raw.expression
        let closure = { (varDict: [String: Float]) -> T? in
            guard let expressionValue = expression.expressionValue(with: varDict, context: nil) as? T else {
                return nil
            }
            return expressionValue
        }
        return closure
    }

}
