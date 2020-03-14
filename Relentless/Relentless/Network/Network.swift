//
//  Network.swift
//  Relentless
//
//  Created by Liu Zechu on 13/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

protocol Network {
    // For the host to start a game. Returns the game room ID.
    func createGame() -> Int
    
    // Free up the game ID stored in the cloud
    func terminateGame(gameId: Int)
    
    func joinGame(userId: String, gameId: Int) -> Bool
    
    func sendPackage(gameId: Int, package: Package, to destination: Player) -> Bool
    
    func receivePackage() -> Package

    func getPlayers(gameId: Int) -> [Player]
}
