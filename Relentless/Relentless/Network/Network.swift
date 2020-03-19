//
//  Network.swift
//  Relentless
//
//  Created by Liu Zechu on 13/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

protocol Network {
    /// This is for the host to start a game. `completion` is called when the game is created
    /// and takes in the game ID created.
    func createGame(completion: @escaping (Int) -> Void)
    
    /// Changes the `GameStatus` to notify other players that the game has ended.
    /// Frees up the game ID stored in the cloud.
    /// - parameters:
    ///     - gameId: the current game ID
    ///     - isGameEndedPrematurely: A host player can call this function
    ///     if they wish to quit the game before the game starts, in which case,
    ///     `isGameEndedPrematurely` should be `true`. Otherwise, it should be `false`.
    func terminateGame(gameId: Int, isGameEndedPrematurely: Bool)
    
    /// This can be called by a player to join the game with the specified game ID.
    /// The host also has to join through this method.
    /// - parameters:
    ///     - completion: a closure that is called to propagate possible errors
    ///     that occur when joining a game. `nil` is passed into it to indicate success.
    func joinGame(userId: String, userName: String, gameId: Int, completion: @escaping (JoinGameError?) -> Void)
    
    /// A non-host player can call this function to quit the game before the game starts.
    /// If a host wishes to quit the game, the whole game will terminate,
    /// and the host should use the `terminateGamePrematurely` function.
    func quitGame(userId: String, gameId: Int)
    
    /// This is called by the host player to start the game.
    func startGame(gameId: Int)
    
    /// This is called by the host player to start a new round with the specified round number.
    func startRound(gameId: Int, roundNumber: Int)
    
    /// This is called by the host player to terminate the current round.
    func terminateRound(gameId: Int, roundNumber: Int, satisfactionLevel: Int)
    
    /// This is called by the host player at the start of the round to send pre-generated items to the target player.
    func sendItems(gameId: Int, items: [Item], to destination: Player)
    
    /// This is called by the host player at the start of the round to send pre-generated orders to the target player.
    func sendOrders(gameId: Int, orders: [Order], to destination: Player)
    
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

    /// Notifies the player when there is a change in the team satisfaction level.
    /// `action` is called upon a change in the satisfaction level
    func attachTeamSatisfactionListener(userId: String, gameId: Int, action: @escaping (Int) -> Void)

    /// Deletes all the packages under a player stored in the cloud.
    /// This is called after the player has received the packages from the cloud.
    func deleteAllPackages(userId: String, gameId: Int)

    /// Notifies the player when there is a new player joining in the game.`action` is called
    /// with an array of all players as the argument, when a new player joins.
    func attachPlayerJoinListener(gameId: Int, action: @escaping ([Player]) -> Void)
    
    /// This method is called by the host and allocates pre-generated items
    /// to all players in `players` at the start of a round.
    func allocateItems(gameId: Int, players: [Player])

    /// This method is called by the host and allocates pre-generated orders
    /// to all players in `players` at the start of a round.
    func allocateOrders(gameId: Int, players: [Player])

}
