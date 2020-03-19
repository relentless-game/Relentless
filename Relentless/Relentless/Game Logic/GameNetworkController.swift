//
//  GameNetworkController.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// To handle `Network` related game actions
protocol GameNetworkController {

    /// Returns `Bool` to indicate if the game was created successfully
    func createGame(userId: String, userName: String)

    /// Returns `Bool` to indicate if the join was successful
    func joinGame(userId: String, userName: String, gameId: Int)

    /// Returns `Bool` to indicate if the package was sent successfully
    func sendPackage(package: Package, to destination: Player) -> Bool

    func receivePackage(package: Package)

}
