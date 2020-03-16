//
//  GameControllerManager.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class GameControllerManager: GameController {

    // properties for game logic
    private var roundTimeInterval: Double = 240 // in seconds
    private var difficultyLevel: Float = 0
    var game: Game?
    var satisfactionBar = SatisfactionBar(minSatisfaction: 0, maxSatisfaction: 100)

    // properties for network
    var isHost: Bool = false
    var network: Network = NetworkManager()

    /// Can be called directly by view or notified by network
    func startGame() {
        guard let gameId = game?.gameId else {
            return
        }
        // initialise all players in the model based on network info
        initialisePlayers(gameId: gameId)
        startRound()
    }

    func endGame() {
        guard let gameId = game?.gameId else {
            return
        }
        network.terminateGame(gameId: gameId)
        game = nil
    }

    func startRound() {
        if isHost {
            // items and orders are generated and allocated by the host only
            initialiseItems()
            initialiseOrders()
        }
        Timer.scheduledTimer(timeInterval: roundTimeInterval, target: self,
                             selector: #selector(endRound), userInfo: nil, repeats: true)
    }

    @objc
    func endRound() {
        // todo: convert satisfaction bar to money
        // todo: check win-lose condition
        difficultyLevel += 0.1
    }

    private func initialisePlayers(gameId: Int) {
        let players = network.getPlayers(gameId: gameId)
        game?.allPlayers = players
    }

    private func initialiseItems() {
        guard let numberOfPlayers = game?.numberOfPlayers else {
            return
        }
        // first choose categories
        let categoryGenerator = CategoryGenerator(numberOfPlayers: numberOfPlayers, difficultyLevel: difficultyLevel)
        let categories = categoryGenerator.generateCategories()

        // allocate items according to chosen categories
        let itemsAllocator = ItemsAllocator(numberOfPlayers: numberOfPlayers, difficultyLevel: difficultyLevel)
        guard let players = game?.allPlayers else {
            return
        }
        itemsAllocator.allocateItems(categories: categories, players: players)

        // update other devices
        network.allocateItems(players: players)
    }

    private func initialiseOrders() {
        let ordersAllocator = OrdersAllocator(difficultyLevel: difficultyLevel)
        guard let players = game?.allPlayers else {
            return
        }
        ordersAllocator.allocateOrders(players: players)
        network.allocateOrders(players: players)
    }
}

extension GameControllerManager {
    func createGame(userId: String, userName: String) -> Bool {
        let gameId = network.createGame()
        // let player = Player(userId: userId)
        // game = GameManager(gameId: gameId, player: Player)
        let joinedGame = joinGame(userId: userId, userName: userName, gameId: gameId)
        return joinedGame
    }

    func joinGame(userId: String, userName: String, gameId: Int) -> Bool {
        //let joinedGame = network.joinGame(userId: userId, gameId: gameId)
        //return joinedGame
        network.joinGame(userId: userId, userName: userName, gameId: gameId)
        return true
    }

    func sendPackage(package: Package, to destination: Player) -> Bool {
        guard let gameId = game?.gameId else {
            return false
        }
        network.sendPackage(gameId: gameId, package: package, to: destination)
//        let sentPackage = network.sendPackage(gameId: gameId, package: package, to: destination)
//        guard sentPackage else {
//            return false
//        }
        game?.removePackage(package: package)
        return true
    }

    func receivePackage(package: Package) {
        game?.addPackage(package: package)
    }
}

extension GameControllerManager {
    func addItem(item: Item) {
        game?.addItem(item: item)
    }

    func removeItem(item: Item) {
        game?.removeItem(item: item)
    }

    func addOrder(order: Order) {
        game?.addOrder(order: order)
    }

    func addPackage(package: Package) {
        game?.addPackage(package: package)
    }

    func removePackage(package: Package) {
        game?.removePackage(package: package)
    }

    func deliverPackage(package: Package, to house: House) {
        guard let isCorrect = game?.checkPackage(package: package, for: house) else {
            return
        }
        guard let order = game?.retrieveOrder(package: package, house: house) else {
            return
        }
        satisfactionBar.update(order: order, isCorrect: isCorrect)
        removePackage(package: package)
        removeOrder(order: order)
    }

    func retrieveOrders(for house: House) -> [Order] {
        guard let orders = game?.retrieveOrders(for: house) else {
            return []
        }
        return orders
    }

    func openPackage(package: Package) {
        game?.openPackage(package: package)
    }

    private func removeOrder(order: Order) {
        game?.removeOrder(order: order)
    }
}
