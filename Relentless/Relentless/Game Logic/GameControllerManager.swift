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
    private var dailyExpense: Int = 100

    var isHost: Bool = false
    var gameCategories: [Category] = []
    var satisfactionBar = SatisfactionBar(minSatisfaction: 0, maxSatisfaction: 100)
    var money: Int = 0

    // properties for model
    var game: Game?
    var players: [Player] {
        game?.allPlayers ?? []
    }
    var playerPackages: [Package] {
        game?.packages ?? []
    }
    var playerItems: [Category : [Item]] {
        var itemsByCategory = [Category: [Item]]()
        game?.player.items.forEach {
            guard let _ = itemsByCategory[$0.category] else {
                itemsByCategory[$0.category] = [$0]
                return
            }
            itemsByCategory[$0.category]?.append($0)
        }
        return itemsByCategory
    }

    // properties for network
    var userId: String? {
        game?.player.userId // unique ID given by Firebase
    }
    var network: Network = NetworkManager()
    var gameId: Int? {
        game?.gameId
    }

    init(userId: String) {
        game?.player.userId = userId
        addObservers()
    }

    @objc func notifyItemChange(notification: Notification) {
           NotificationCenter.default.post(name: .didChangeItems, object: nil)
    }

    @objc func notifyPackageChange(notification: Notification) {
           NotificationCenter.default.post(name: .didChangePackages, object: nil)
    }

    /// Can be called directly by view or notified by network
    func startGame() {
        guard let gameId = gameId else {
            return
        }
        guard isHost else {
            return
        }
        network.startGame(gameId: gameId)
    }

    func endGame() {
        guard let gameId = gameId else {
            return
        }
        network.terminateGame(gameId: gameId, isGameEndedPrematurely: false)
        game = nil
    }

    func startRound() {
        Timer.scheduledTimer(timeInterval: roundTimeInterval, target: self,
            selector: #selector(endRound), userInfo: nil, repeats: true)

        guard isHost else {
            return
        }

        // items and orders are generated and allocated by the host only
        initialiseItems()
        initialiseOrders()

        // network is notified to start round by the host only
        if let gameId = gameId, let roundNumber = game?.currentRoundNumber {
            network.startRound(gameId: gameId, roundNumber: roundNumber)
        }
    }

    @objc
    func endRound() {
        guard isHost, let gameId = gameId, let roundNumber = game?.currentRoundNumber else {
            return
        }
        network.terminateRound(gameId: gameId, roundNumber: roundNumber, satisfactionLevel: satisfactionBar.currentSatisfaction)
        difficultyLevel += 0.1
    }

    private func initialiseItems() {
        guard let numberOfPlayers = game?.numberOfPlayers, let gameId = gameId else {
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
        gameCategories = Array(itemsAllocator.generatedItemsByCategory.keys)

        // update other devices
        network.allocateItems(gameId: gameId, players: players)
    }

    private func initialiseOrders() {
        let ordersAllocator = OrdersAllocator(difficultyLevel: difficultyLevel)
        guard let players = game?.allPlayers, let gameId = gameId else {
            return
        }
        ordersAllocator.allocateOrders(players: players)
        
        // update other devices
        network.allocateOrders(gameId: gameId, players: players)
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(notifyItemChange(notification:)), name: .didChangeItemsInModel, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notifyPackageChange(notification:)), name: .didChangePackagesInModel, object: nil)
    }
}

extension GameControllerManager {
    func createGame(userName: String) {
        network.createGame(completion: { gameId in
            guard let userId = self.userId else {
                return
            }
            let userName = self.generateDummyUserName()
            let player = Player(userId: userId, userName: userName, profileImage: nil)
            self.game = GameManager(gameId: gameId, player: player)
            self.joinGame(userName: userName, gameId: gameId)
            self.isHost = true
            NotificationCenter.default.post(name: .didReceiveGameId, object: nil)
        })
    }

    internal func joinGame(userName: String, gameId: Int) {
        guard let userId = self.userId else {
            return
        }
        let userName = generateDummyUserName()
        network.joinGame(userId: userId, userName: userName, gameId: gameId, completion: { error in
            if let error = error {
                self.handleUnsuccessfulJoin(error: error)
            } else { // successfully joined the game
                self.handleSuccessfulJoin(userId: userId, gameId: gameId)
            }
        })
    }

    func leaveGame(userId: String) {
        guard let gameId = gameId else {
            return
        }
        game = nil

        if isHost {
            network.terminateGame(gameId: gameId, isGameEndedPrematurely: true)
        } else {
            network.quitGame(userId: userId, gameId: gameId)
        }
    }

    func sendPackage(package: Package, to destination: Player) -> Bool {
        guard let gameId = gameId else {
            return false
        }
        network.sendPackage(gameId: gameId, package: package, to: destination)
        game?.removePackage(package: package)
        return true
    }

    private func handleUnsuccessfulJoin(error: JoinGameError) {
        switch error {
        case .invalidGameId:
            NotificationCenter.default.post(name: .invalidGameId, object: nil)
        case .gameAlreadyPlaying:
            NotificationCenter.default.post(name: .gameAlreadyPlaying, object: nil)
        case .gameRoomFull:
            NotificationCenter.default.post(name: .gameRoomFull, object: nil)
        }
    }

    private func handleSuccessfulJoin(userId: String, gameId: Int) {
        self.network.attachPlayerJoinListener(gameId: gameId, action: self.onNewPlayerDidJoin)
        self.network.attachGameStatusListener(gameId: gameId, action: self.onGameStatusDidChange)
        self.network.attachTeamSatisfactionListener(userId: userId, gameId: gameId,
                                                    action: self.onTeamSatisfactionChange)
        self.network.attachItemsListener(userId: userId, gameId: gameId, action: { items in
            self.game?.player.items = Set(items)
        })
        self.network.attachOrdersListener(userId: userId, gameId: gameId, action: { orders in
            self.initialiseHouses(with: orders)
        })
        self.network.attachPackageListener(userId: userId, gameId: gameId, action: { package in
            self.game?.addPackage(package: package)
        })
    }

    private func onNewPlayerDidJoin(players: [Player]) {
        game?.allPlayers = players
        NotificationCenter.default.post(name: .newPlayerDidJoin, object: nil)
    }

    // for game status listener
    private func onGameStatusDidChange(gameStatus: GameStatus) {
        let didStartGame = gameStatus.isGamePlaying && !gameStatus.isRoundPlaying && gameStatus.currentRound == 0
        let didEndGame = !gameStatus.isGamePlaying && !gameStatus.isRoundPlaying
        let didStartRound = gameStatus.isGamePlaying && gameStatus.isRoundPlaying
        let didEndRound = gameStatus.isGamePlaying && !gameStatus.isRoundPlaying && gameStatus.currentRound != 0
        let didEndGamePrematurely = gameStatus.isGameEndedPrematurely

        if didEndGamePrematurely {
            NotificationCenter.default.post(name: .didEndGamePrematurely, object: nil)
        } else if didStartGame {
            NotificationCenter.default.post(name: .didStartGame, object: nil)
        } else if didEndGame {
            NotificationCenter.default.post(name: .didEndGame, object: nil)
        } else if didStartRound {
            NotificationCenter.default.post(name: .didStartRound, object: nil)
            game?.incrementRoundNumber()
        } else if didEndRound {
            NotificationCenter.default.post(name: .didEndRound, object: nil)
        }
    }

    private func onTeamSatisfactionChange(satisfactionLevel: Int) {
        money += satisfactionLevel * 2 // arbitrary translation rate; to change next time
        money -= dailyExpense

        guard isHost else {
            return
        }

        // the host checks the lose condition and ends the game if fulfilled
        if money <= 0 {
            endGame()
        }
    }

    private func initialiseHouses(with orders: [Order]) {
        guard let numOfHouses = game?.defaultNumberOfHouses else {
            return
        }
        var splitOrders = [[Order]]()
        for index in 1...numOfHouses {
            splitOrders[index] = []
        }
        for i in 0..<orders.count {
            splitOrders[i % numOfHouses].append(orders[i])
        }
        var houses = [House]()
        for orders in splitOrders {
            houses.append(House(orders: Set(orders)))
        }
        game?.houses = houses
    }

    private func generateDummyUserName() -> String {
        return "Player " + String(players.count + 1)
    }
}

extension GameControllerManager {
    func addItem(item: Item) {
        game?.addItem(item: item)
    }

    func removeItem(item: Item) {
        game?.removeItem(item: item)
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
        removePackage(package: package)
        removeOrder(order: order)
        updateGameProperties(order: order, isCorrect: isCorrect)
    }

    func openPackage(package: Package) {
        game?.openPackage(package: package)
    }

    func retrieveOrders(for house: House) -> Set<Order> {
        guard let orders = game?.retrieveOrders(for: house) else {
            return []
        }
        return Set(orders)
    }

    private func removeOrder(order: Order) {
        game?.removeOrder(order: order)
    }

    private func updateGameProperties(order: Order, isCorrect: Bool) {
        satisfactionBar.update(order: order, isCorrect: isCorrect)
        if satisfactionBar.currentSatisfaction <= 0 {
            endRound()
        }
    }

}
