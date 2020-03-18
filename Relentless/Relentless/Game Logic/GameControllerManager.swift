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
    let userId: String // unique ID given by Firebase
    var isHost: Bool = false
    var network: Network = NetworkManager()
    
    init(userId: String) {
        self.userId = userId // do we still need this then?
        game?.player.userId = userId
    }

    /// Can be called directly by view or notified by network
    func startGame() {
        guard let gameId = game?.gameId else {
            return
        }
        guard isHost else {
            return
        }
        network.startGame(gameId: gameId)
        
        // Commented out because this is taken care of under joinGame()
        // initialise all players in the model based on network info
        // initialisePlayers(gameId: gameId)
        startRound()
    }

    func endGame() {
        guard let gameId = game?.gameId else {
            return
        }
        network.terminateGame(gameId: gameId, isGameEndedPrematurely: false)
        game = nil
    }

    func startRound() {
        if isHost {
            // items and orders are generated and allocated by the host only
            initialiseItems()
            initialiseOrders()
            
            Timer.scheduledTimer(timeInterval: roundTimeInterval, target: self,
                                 selector: #selector(endRound), userInfo: nil, repeats: true)
        
            if let gameId = game?.gameId, let roundNumber = game?.currentRoundNumber {
                network.startRound(gameId: gameId, roundNumber: roundNumber)
            }
        }
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

    @objc
    func endRound() {
        // todo: convert satisfaction bar to money
        // todo: check win-lose condition
        guard isHost, let gameId = game?.gameId, let roundNumber = game?.currentRoundNumber else {
            return
        }
        network.terminateRound(gameId: gameId, roundNumber: roundNumber)
        difficultyLevel += 0.1
    }

//    private func initialisePlayers(gameId: Int) {
//        network.attachPlayerJoinListener(gameId: gameId, action: onNewPlayerDidJoin)
//    }
    
    private func onNewPlayerDidJoin(players: [Player]) {
        game?.allPlayers = players
        NotificationCenter.default.post(name: .newPlayerDidJoin, object: nil)
    }

    private func initialiseItems() {
        guard let numberOfPlayers = game?.numberOfPlayers, let gameId = game?.gameId else {
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
        network.allocateItems(gameId: gameId, players: players)
    }

    private func initialiseOrders() {
        let ordersAllocator = OrdersAllocator(difficultyLevel: difficultyLevel)
        guard let players = game?.allPlayers, let gameId = game?.gameId else {
            return
        }
        ordersAllocator.allocateOrders(players: players)
        
        // update other devices
        network.allocateOrders(gameId: gameId, players: players)
    }
}

extension GameControllerManager {
    func createGame(userId: String, userName: String) {
        network.createGame(completion: { gameId in
            let player = Player(userId: userId, userName: userName, profileImage: nil)
            self.game = GameManager(gameId: gameId, player: player)
            self.joinGame(userId: userId, userName: userName, gameId: gameId)
            
            NotificationCenter.default.post(name: .didReceiveGameId, object: nil)
        })
    }
    
    internal
    func joinGame(userId: String, userName: String, gameId: Int) {
        network.joinGame(userId: userId, userName: userName, gameId: gameId, completion: { error in
            if let error = error {
                switch error {
                case .invalidGameId:
                    NotificationCenter.default.post(name: .invalidGameId, object: nil)
                case .gameAlreadyPlaying:
                    NotificationCenter.default.post(name: .gameAlreadyPlaying, object: nil)
                case .gameRoomFull:
                    NotificationCenter.default.post(name: .gameRoomFull, object: nil)
                }
            } else { // successfully joined the game
                self.network.attachPlayerJoinListener(gameId: gameId, action: self.onNewPlayerDidJoin)
                self.network.attachGameStatusListener(gameId: gameId, action: self.onGameStatusDidChange)
                self.network.attachItemsListener(userId: userId, gameId: gameId, action: { items in
                    // TODO: what to do when items are received?
                    
                    NotificationCenter.default.post(name: .didReceiveItems, object: nil)
                })
                self.network.attachOrdersListener(userId: userId, gameId: gameId, action: { orders in
                    // TODO: what to do when orders are received?
                    
                    NotificationCenter.default.post(name: .didReceiveOrders, object: nil)
                })
                self.network.attachPackageListener(userId: userId, gameId: gameId, action: { package in
                    // TODO: what to do when a package is received?
                    
                    NotificationCenter.default.post(name: .didReceivePackage, object: nil)
                })
            }
        })
    }

    func sendPackage(package: Package, to destination: Player) -> Bool {
        guard let gameId = game?.gameId else {
            return false
        }
        network.sendPackage(gameId: gameId, package: package, to: destination)
        game?.removePackage(package: package)
        return true
    }

    // don't use this
    func receivePackage(package: Package) {
        //game?.addPackage(package: package)
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
        //game?.addPackage(package: package)
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

    func retrieveOrders(for house: House) -> Set<Order> {
        guard let orders = game?.retrieveOrders(for: house) else {
            return []
        }
        return Set(orders)
    }

    func openPackage(package: Package) {
        game?.openPackage(package: package)
    }

    private func removeOrder(order: Order) {
        game?.removeOrder(order: order)
    }
}
