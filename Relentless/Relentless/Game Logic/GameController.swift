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

    var gameCategories: [Category] { get }
    var satisfactionBar: SatisfactionBar { get set }
    var money: Int { get }

    func endGame()

    func pauseRound()

    func resumeRound()
}
