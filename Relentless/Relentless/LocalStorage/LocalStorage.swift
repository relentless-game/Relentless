//
//  LocalStorage.swift
//  Relentless
//
//  Created by Chow Yi Yin on 3/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// Handles local storage of the player's score information.
protocol LocalStorage {

    func getExistingScores() throws -> [ScoreRecord]

    /// updates the existing scoreboard 
    func updateScoreBoard(with newScore: ScoreRecord)
}
