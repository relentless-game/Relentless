//
//  GameController.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// Handles game logic
protocol GameController: GameNetworkController, GameModelController {

    var isHost: Bool { get set }
    var gameCategories: [Category] { get }
    var satisfactionBar: SatisfactionBar { get set }
    var money: Int { get }
    var gameStatus: GameStatus? { get set } // for pausing
    var pauseCountDown: Int { get set } // for pausing
    
    func startGame()

    func endGame()

    func startRound()

    func pauseRound()

    func resumeRound()
}
