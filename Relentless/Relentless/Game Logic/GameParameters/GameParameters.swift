//
//  GameParameters.swift
//  Relentless
//
//  Created by Yi Wai Chow on 27/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class GameParameters {
    typealias I = (([String: Double]) -> Int?)
    typealias D = (([String: Double]) -> Double?)

    var difficultyLevel: Double = 1.0

    var varDict: [String: Double] {
        [VariableNames.difficultyLevelVarName: difficultyLevel]
    }

    /// The following properties do not vary with the difficulty level
    static var numOfPlayersRange = 3...6
    static var satisfactionRange: ClosedRange<Double> = 0...100
    static var difficultyRange: ClosedRange<Double> = 1.0...10.0

    /// The following are closures that take in parameters (currently only difficulty level)
    /// They are used to compute the actual variable values
    internal var numOfHousesExpression: I?
    internal var difficultyChangeExpression: D?
    internal var roundTimeExpression: I?
    internal var dailyExpenseExpression: I?
    internal var minHouseSatisfactionFactorExpression: D?
    internal var maxHouseSatisfactionFactorExpression: D?
    internal var satisfactionToMoneyTranslationExpression: I?
    internal var satisfactionRunOutPenaltyExpression: D?
    internal var satisfactionUnitDecreaseExpression: D?

    /// The following are closures that will be used in calculating satisfaction changes in `SatisfactionBar`
    internal var correctPackageSatisfactionChangeExpression: D?
    internal var wrongPackageSatisfactionChangeExpression: D?

    /// The following properties are computed based on the closures above and take in a dictionary
    /// that specifies the variable values in the closure expressions
    var numOfHouses: Int {
        let defaultValue: Int = 5
        return numOfHousesExpression?(varDict) ?? defaultValue
    }
    var difficultyChange: Double {
        let defaultValue: Double = 0.5
        return difficultyChangeExpression?(varDict) ?? defaultValue
    }
    var roundTime: Int {
        let defaultValue: Int = 240
        return roundTimeExpression?(varDict) ?? defaultValue
    }
    var dailyExpense: Int {
        let defaultValue: Int = 50
        return dailyExpenseExpression?(varDict) ?? defaultValue
    }
    var houseSatisfactionFactorRange: ClosedRange<Double> {
        let defaultMinValue: Double = 0.5
        let minHouseSatisfactionFactor = minHouseSatisfactionFactorExpression?(varDict) ?? defaultMinValue

        let defaultMaxValue: Double = 1.0
        let maxHouseSatisfactionFactor = maxHouseSatisfactionFactorExpression?(varDict) ?? defaultMaxValue
        return minHouseSatisfactionFactor...maxHouseSatisfactionFactor
    }
    var satisfactionToMoneyTranslation: Int {
        let defaultValue: Int = 2
        return satisfactionToMoneyTranslationExpression?(varDict) ?? defaultValue
    }
    var satisfactionRunOutPenalty: Double {
        let defaultValue: Double = 0.2 * GameParameters.satisfactionRange.upperBound
        return satisfactionRunOutPenaltyExpression?(varDict) ?? defaultValue
    }
    var satisfactionUnitDecrease: Double {
        let defaultValue: Double = (GameParameters.satisfactionRange.upperBound / Double(roundTime)).rounded(.up)
        return satisfactionUnitDecreaseExpression?(varDict) ?? defaultValue
    }

    func incrementDifficulty() {
        difficultyLevel += difficultyChange
        if difficultyLevel > GameParameters.difficultyRange.upperBound {
            difficultyLevel = GameParameters.difficultyRange.upperBound
        }
    }

    func reset() {
        difficultyLevel = GameParameters.difficultyRange.lowerBound
    }

}
