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
    typealias I = ([String: Double]) -> Int?
    typealias D = ([String: Double]) -> Double?
    typealias IR = ClosedRange<Int>
    typealias DR = ClosedRange<Double>

    let configValues: ConfigValues

    init(configValues: ConfigValues) {
        self.configValues = configValues
    }

    func parse() -> GameParameters? {
        let gameParameters = GameParameters()

        guard parseNumbers(gameParameters: gameParameters) else {
            return nil
        }

        guard parseStrings(gameParameters: gameParameters) else {
            return nil
        }

        return gameParameters
    }

    internal func parseNumbers(gameParameters: GameParameters) -> Bool {
        guard let difficultyRange: DR = parseNumbersToRange(minKey: ConfigKeys.minDifficultyLevel,
                                                            maxKey: ConfigKeys.maxDifficultyLevel),
            let satisfactionRange: DR = parseNumbersToRange(minKey: ConfigKeys.minSatisfaction,
                                                            maxKey: ConfigKeys.maxSatisfaction)
            else {
                return false
        }
        gameParameters.difficultyRange = difficultyRange
        gameParameters.satisfactionRange = satisfactionRange
        return true
    }

    internal func parseStrings(gameParameters: GameParameters) -> Bool {
        guard let numOfHouses: I = parseStringExpression(key: ConfigKeys.numOfHouses),
            let difficultyChange: D = parseStringExpression(key: ConfigKeys.difficultyChange),
            let roundTime: I = parseStringExpression(key: ConfigKeys.roundTime),
            let dailyExpense: I = parseStringExpression(key: ConfigKeys.dailyExpense),
            let correctPackageSatisfactionChange: D = parseStringExpression(key:
                ConfigKeys.correctPackageSatisfactionChange),
            let wrongPackageSatisfactionChange: D = parseStringExpression(key: ConfigKeys.wrongPackageSatisfactionChange),
            let minHouseSatisfactionFactor: D = parseStringExpression(key: ConfigKeys.minHouseSatisfactionFactor),
            let maxHouseSatisfactionFactor: D = parseStringExpression(key: ConfigKeys.maxHouseSatisfactionFactor),
            let satisfactionToMoneyTranslation: I = parseStringExpression(key: ConfigKeys.satisfactionToMoneyTranslation),
            let satisfactionRunOutPenalty: D = parseStringExpression(key: ConfigKeys.satisfactionRunOutPenalty),
            let satisfactionUnitDecrease: D = parseStringExpression(key: ConfigKeys.satisfactionUnitDecrease)
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
        guard let minValue: T = configValues.getNumber(for: minKey) else {
            return nil
        }
        guard let maxValue: T = configValues.getNumber(for: maxKey) else {
            return nil
        }
        return minValue...maxValue
    }

    internal func parseStringExpression<T>(key: String) -> (([String: Double]) -> T?)? {
        guard let raw = configValues.getString(for: key) else {
            return nil
        }
        guard let expression = raw.expression else {
            return nil
        }
        let closure = { (varDict: [String: Double]) -> T? in
            guard let expressionValue = expression.expressionValue(with: varDict, context: nil) as? T else {
                return nil
            }
            return expressionValue
        }
        return closure
    }

}
