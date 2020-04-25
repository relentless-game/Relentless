//
//  HostNetwork.swift
//  Relentless
//
//  Created by Yi Wai Chow on 25/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

protocol HostNetwork {

    /// This is for the host to start a game. `completion` is called when the game is created
    /// and takes in the game ID created.
    func createGame(completion: @escaping (Int) -> Void)

    /// This is called by the host player to start the game.
    /// - parameters:
    ///     - completion: a closure that is called to propagate possible errors
    ///     that occur when starting a game. `nil` is passed into it to indicate success
    func startGame(gameId: Int, configValues: LocalConfigValues, completion: @escaping (StartGameError?) -> Void)

    /// This is called by the host player to start a new round with the specified round number.
    func startRound(gameId: Int, roundNumber: Int)

    /// This method is called by the host and allocates pre-generated items
    /// to all players in `players` at the start of a round.
    func allocateItems(gameId: Int, players: [Player])

    /// This method is called by the host and allocates pre-generated orders
    /// to all players in `players` at the start of a round.
    func allocateOrders(gameId: Int, players: [Player])

    /// This method is called by the host to inform all players of the limit for the number of items in packages
    func setPackageItemsLimit(gameId: Int, limit: Int)

    /// Sends the round item specifications to all players in the game
   func broadcastRoundItemSpecification(gameId: Int, roundItemSpecification: RoundItemSpecifications)

    /// This method is to set the number of players range for the game in the network
    func initialiseNumberOfPlayersRange(gameId: Int, min: Int, max: Int)

}
