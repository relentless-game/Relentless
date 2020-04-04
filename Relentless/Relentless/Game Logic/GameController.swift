//
//  GameController.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// Handles game logic
protocol GameController: GameModelController, GameNetworkController {

    var gameCategories: [Category] { get }
    var satisfactionBar: SatisfactionBar { get set }
    var money: Int { get }
    var isHost: Bool { get set }
    var gameParameters: GameParameters { get }
    
    var gameStatus: GameStatus? { get set } // for pausing
    var pauseCountDown: Int { get set } // for pausing
    
    func endGame()

    func pauseRound()

    func resumeRound()
}
