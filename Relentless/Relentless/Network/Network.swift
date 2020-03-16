//
//  Network.swift
//  Relentless
//
//  Created by Liu Zechu on 13/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

protocol Network {
    /// This is for the host to start a game. Returns the game room ID.
    func createGame() -> Int
    
    /// Changes the `GameStatus` to notify other players that the game has ended.
    /// Frees up the game ID stored in the cloud.
    func terminateGame(gameId: Int)
    
    /// This can be called by a player to join the game with the specified game ID.
    /// The host also has to join through this method.
    func joinGame(userId: String, userName: String, gameId: Int)
    
    /// This is called by the host player to start the game.
    func startGame(gameId: Int)
    
    /// This is called by the host player to start a new round with the specified round number.
    func startRound(gameId: Int, roundNumber: Int)
    
    /// This is called by the host player to terminate the current round.
    func terminateRound(gameId: Int, roundNumber: Int)
    
    /// This is called by the host player at the start of the round to send pre-generated items to the target player.
    func sendItems(gameId: Int, items: [Item], to destination: Player)
    
    /// This is called by the host player at the start of the round to send pre-generated orders to the target player.
    func sendOrders(gameId: Int, orders: [Order], to destination: Player)
    
    // Don't use this. Use `attachItemsListener`
    /// Other non-host players can use this method to obtain their items for this round.
    func receiveItems(userId: String, gameId: Int) -> [Item]
    
    // Don't use this. Use `attachOrdersListener`
    /// Other non-host players can use this method to obtain their orders for this round.
    func receiveOrders(userId: String, gameId: Int) -> [Order]
    
    /// Notifies non-host player to give them their items for this round. `action` is called upon receiving the items.
    func attachItemsListener(userId: String, gameId: Int, action: @escaping ([Item]) -> Void)
    
    /// Notifies non-host player to give them their orders for this round. `action` is called upon receiving the orders.
    func attachOrdersListener(userId: String, gameId: Int, action: @escaping ([Order]) -> Void)
    
    /// This can be called by any player to send a package to the target player.
    func sendPackage(gameId: Int, package: Package, to destination: Player)
    
    /// Notifies the player when a package is received. `action` is called upon receiving a new package.
    func attachPackageListener(userId: String, gameId: Int, action: @escaping (Package) -> Void)
    
    /// Notifies the player when there is a change in the game status, e.g. whether a game/round has started/ended.
    /// `action` is called upon any change in game status.
    func attachGameStatusListener(gameId: Int, action: @escaping (GameStatus) -> Void)
    
    /// Deletes all the packages under a player stored in the cloud.
    /// This is called after the player has received the packages from the cloud.
    func deleteAllPackages(userId: String, gameId: Int)

    // Don't use this. Use `attachPackageListener`
    func receivePackage() -> Package

    // Don't use this. Use `attachPlayerListListener`
    func getPlayers(gameId: Int) -> [Player]

    /// Notifies the player when there is a new player joining in the game.`action` is called when a new player joins.
    func attachPlayerJoinListener(gameId: Int, action: @escaping ([Player]) -> Void)
    
    /// This method is called by the host and allocates pre-generated items to all players in `players` at the start of a round.
    func allocateItems(gameId: Int, players: [Player])

    /// This method is called by the host and allocates pre-generated orders to all players in `players` at the start of a round.
    func allocateOrders(gameId: Int, players: [Player])

}
