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

    /// Player automatically joins game upon successful creation of game
    /// The creator needs to input their username when creating the game.
    func createGame(userName: String)

    func joinGame(gameId: Int, userName: String)
    
    /// Enables the player to edit their username and profile image before the game starts
    func editUserInfo(username: String, profile: PlayerAvatar)

    /// To leave the game before it starts
    /// Terminates the game if host calls this method
    func leaveGame(userId: String)

    /// Returns `Bool` to indicate if the package was sent successfully
    func sendPackage(package: Package, to destination: Player) -> Bool
}
