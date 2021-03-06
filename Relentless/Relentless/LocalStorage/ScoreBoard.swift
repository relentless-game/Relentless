//
//  ScoreBoard.swift
//  Relentless
//
//  Created by Chow Yi Yin on 3/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// Handles the score board at the end of the game.
protocol ScoreBoard {

    func getExistingScores() throws -> [ScoreRecord]

    /// updates the existing scoreboard 
    func updateScoreBoard(with newScore: ScoreRecord)
}

enum ScoreBoardError: Error {
    case loadError
    case updateError
}
