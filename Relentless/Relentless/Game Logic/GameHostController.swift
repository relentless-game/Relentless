//
//  GameHostController.swift
//  Relentless
//
//  Created by Yi Wai Chow on 26/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

protocol GameHostController {

    /// Player automatically joins game upon successful creation of game
    /// The creator needs to input their username when creating the game.
    func createGame(username: String)

    func startGame()

    /// Attempts to start round. Does nothing if there is no game currently
    func startRound()

}
