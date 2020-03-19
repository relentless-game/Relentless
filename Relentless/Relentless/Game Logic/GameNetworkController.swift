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

    var network: Network { get }
    var userId: String? { get }
    var gameId: Int? { get }

    func createGame(userName: String)

    func joinGame(userName: String, gameId: Int)

    /// To leave the game before it starts
    /// Terminates the game if host calls this method
    func leaveGame(userId: String)

    /// Returns `Bool` to indicate if the package was sent successfully
    func sendPackage(package: Package, to destination: Player) -> Bool
}
