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
    func createGame()

    func startGame()

    func startRound()

}
