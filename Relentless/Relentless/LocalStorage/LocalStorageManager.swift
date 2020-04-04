//
//  LocalStorageManager.swift
//  Relentless
//
//  Created by Chow Yi Yin on 3/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class LocalStorageManager: LocalStorage {

    var scoreBoard: ScoreBoard = JsonScoreBoardStorage()

    func getExistingScores() throws -> [ScoreRecord] {
        try scoreBoard.getExistingScores()
    }

    /// updates the existing scoreboard and returns the updated scores in descending order
    func updateScoreBoard(with newScore: ScoreRecord) throws {
        try scoreBoard.updateScoreBoard(with: newScore)
    }
}
