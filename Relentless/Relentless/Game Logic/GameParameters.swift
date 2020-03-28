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
    static let difficultyRange: ClosedRange<Float> = 1.0...10.0
    static var difficultyChange: Float = 0.5

    static var roundTime: Double = 240
    static var dailyExpense: Int = 50

    static var defaultSatisfactionChange: Float = 25
    static var satisfactionIncreaseForCorrectItem: Float = 1

    init(difficultyLevel: Float) {
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
