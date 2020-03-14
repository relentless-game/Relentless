//
//  GameManager.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class GameControllerManager: GameController {

    var isHost: Bool = false
    var network: Network = NetworkManager()
    var game: Game?

    func startGame() {
        guard let gameId = game?.id else {
            return
        }
        let players = network.getPlayers(gameId: gameId)
        addPlayers(players: players)
        // generate and assign items and orders
        // update network
    }

    func endGame() {
        // todo
    }

    func createGame(userId: String) {
        let gameId = network.createGame()
        // game = GameManager(id: gameId)
        joinGame(userId: userId, gameId: gameId)
    }

    func joinGame(userId: String, gameId: Int) {
        let joinedGame = network.joinGame(userId: userId, gameId: gameId)
        if joinedGame {
            game?.player = Player(userId: userId)
        }
    }

    func sendPackage(package: Package, to destination: Player) {
        guard let gameId = game?.id else {
            return
        }
        let sentPackage = network.sendPackage(gameId: gameId, package: package, to: destination)
        guard sentPackage else {
            return
        }
        game?.removePackage(package: package)
    }

    func receivePackage(package: Package) {
        game?.addPackage(package: package)
    }

    func addItem(item: Item) {
        game?.addItem(item: item)
    }

    func removeItem(item: Item) {
        game?.removeItem(item: item)
    }

    func addPackage(package: Package) {
        game?.addPackage(package: package)
    }

    func removePackage(package: Package) {
        game?.removePackage(package: package)
    }

    func deliverPackage(package: Package, to house: House) {
        guard let correctPackage = game?.checkPackage(package: package, for: house) else {
            return
        }
        if correctPackage {
            // handle correct package
        } else {
            // handle wrong package
        }
    }

    func addOtherPlayer(player: Player) {
        game?.addOtherPlayer(player: player)
    }

    func removeOtherPlayer(player: Player) {
        game?.removeOtherPlayer(player: player)
    }

    func retrieveOrders(for house: House) -> [Order] {
        guard let orders = game?.retrieveOrders(for: house) else {
            return []
        }
        return orders
    }

    private func addPlayers(players: [Player]) {
        for player in players where player != game?.player {
            game?.addOtherPlayer(player: player)
        }
    }

}
