//
//  LocalStorageManager.swift
//  Relentless
//
//  Created by Chow Yi Yin on 3/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// The implementation class of `LocalStorage` which handles local storage of the player's score information.
class LocalStorageManager: LocalStorage {

    var scoreBoard: ScoreBoard = JsonScoreBoardStorage()

    func getExistingScores() throws -> [ScoreRecord] {
        try scoreBoard.getExistingScores()
    }

    /// updates the existing scoreboard
    func updateScoreBoard(with newScore: ScoreRecord) {
        scoreBoard.updateScoreBoard(with: newScore)
    }
}
