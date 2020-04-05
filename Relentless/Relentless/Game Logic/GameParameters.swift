//
//  GameParameters.swift
//  Relentless
//
//  Created by Yi Wai Chow on 27/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class GameParameters {

    var difficultyLevel: Float

    /// The following properties do not vary with the difficulty level
    static let numOfPlayersRange = 1...6 // Minimum is set at 1 for testing purposes. Should be changed to 3

    static let difficultyRange: ClosedRange<Float> = 1.0...10.0
    static var difficultyChange: Float = 0.5

    static var roundTime: Int = 240
    static var dailyExpense: Int = 50

    static var minSatisfaction: Int = 0
    static var maxSatisfaction: Int = 100
    static var defaultSatisfactionChange: Float = 25
    static var satisfactionIncreaseForCorrectItem: Float = 1

    static var houseSatisfactionFactorRange: ClosedRange<Float> = 0.5...1.0
    static var satisfactionToMoneyTranslation: Int = 2

    static var satisfactionRunOutPenalty: Float {
        0.2 * Float(maxSatisfaction)
    }

    static var satisfactionUnitDecrease: Float {
        (Float(maxSatisfaction) / Float(roundTime)).rounded(.up)
    }

    init(difficultyLevel: Float) {
        assert(GameParameters.difficultyRange.contains(difficultyLevel))
        self.difficultyLevel = difficultyLevel
    }

    func incrementDifficulty() {
        difficultyLevel += GameParameters.difficultyChange
        if difficultyLevel > GameParameters.difficultyRange.upperBound {
            difficultyLevel = GameParameters.difficultyRange.upperBound
        }
    }

    func reset() {
        // todo: difficulty level should revert to initially set value
        difficultyLevel = 0
    }

}
