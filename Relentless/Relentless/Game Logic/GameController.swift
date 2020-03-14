//
//  GameController.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

protocol GameController: GameNetworkController, GameModelController {

    var isHost: Bool { get set }

    func startGame()

    func endGame()
}
