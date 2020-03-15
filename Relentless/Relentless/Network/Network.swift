//
//  Network.swift
//  Relentless
//
//  Created by Liu Zechu on 13/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

protocol Network {
    // This is for the host to start a game. Returns the game room ID.
    func createGame() -> Int
    
    // Free up the game ID stored in the cloud
    func terminateGame(gameId: Int)
    
    func joinGame(userId: String, gameId: Int)
    
    // Called by the host player to start the game
    func startGame(gameId: Int)
    
    func startRound(gameId: Int, roundNumber: Int)
    
    func terminateRound(gameId: Int, roundNumber: Int)
    
    // Called by the host player to send pre-generated items to the target player
    func sendItems(gameId: Int, items: [Item], to destination: Player)
    
    // Called by the host player to send pre-generated orders to the target player
    func sendOrders(gameId: Int, orders: [Order], to destination: Player)
    
    func receiveItems(userId: String, gameId: Int) -> [Item]
    
    func receiveOrders(userId: String, gameId: Int) -> [Order]
    
    func sendPackage(gameId: Int, package: Package, to destination: Player)
    
    // Notifies when a package is received. `action` is called upon receiving a new package.
    func attachPackageListener(userId: String, gameId: Int, action: @escaping (Package) -> Void)
    
}
