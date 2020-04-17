//
//  GameParameters.swift
//  Relentless
//
//  Created by Yi Wai Chow on 27/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class GameParameters {
    typealias I = (([String: Float]) -> Int?)
    typealias F = (([String: Float]) -> Float?)

    var difficultyLevel: Float = 1.0

    var varDict: [String: Float] {
        [VariableNames.difficultyLevelVarName: difficultyLevel]
    }

    /// The following properties do not vary with the difficulty level
    static var numOfPlayersRange = 3...6
    static var satisfactionRange: ClosedRange<Float> = 0...100
    static var difficultyRange: ClosedRange<Float> = 1.0...10.0

    /// The following are closures that take in parameters (currently only difficulty level)
    /// They are used to compute the actual variable values
    internal var numOfHousesExpression: I?
    internal var difficultyChangeExpression: F?
    internal var roundTimeExpression: I?
    internal var dailyExpenseExpression: I?
    internal var minHouseSatisfactionFactorExpression: F?
    internal var maxHouseSatisfactionFactorExpression: F?
    internal var satisfactionToMoneyTranslationExpression: I?
    internal var satisfactionRunOutPenaltyExpression: F?
    internal var satisfactionUnitDecreaseExpression: F?

    /// The following are closures that will be used in calculating satisfaction changes in `SatisfactionBar`
    internal var correctPackageSatisfactionChangeExpression: F?
    internal var wrongPackageSatisfactionChangeExpression: F?

    /// The following properties are computed based on the closures above and take in a dictionary
    /// that specifies the variable values in the closure expressions
    var numOfHouses: Int {
        let defaultValue: Int = 5
        return numOfHousesExpression?(varDict) ?? defaultValue
    }
    var difficultyChange: Float {
        let defaultValue: Float = 0.5
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
    var houseSatisfactionFactorRange: ClosedRange<Float> {
        let defaultMinValue: Float = 0.5
        let minHouseSatisfactionFactor = minHouseSatisfactionFactorExpression?(varDict) ?? defaultMinValue

        let defaultMaxValue: Float = 1.0
        let maxHouseSatisfactionFactor = maxHouseSatisfactionFactorExpression?(varDict) ?? defaultMaxValue
        return minHouseSatisfactionFactor...maxHouseSatisfactionFactor
    }
    var satisfactionToMoneyTranslation: Int {
        let defaultValue: Int = 2
        return satisfactionToMoneyTranslationExpression?(varDict) ?? defaultValue
    }
    var satisfactionRunOutPenalty: Float {
        let defaultValue = 0.2 * GameParameters.satisfactionRange.upperBound
        return satisfactionRunOutPenaltyExpression?(varDict) ?? defaultValue
    }
    var satisfactionUnitDecrease: Float {
        let defaultValue = (GameParameters.satisfactionRange.upperBound / Float(roundTime)).rounded(.up)
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
