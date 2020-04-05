//
//  GameHostControllerManager.swift
//  Relentless
//
//  Created by Yi Wai Chow on 26/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class GameHostControllerManager: GameControllerManager, GameHostController {

    var hostParameters: GameHostParameters? {
        gameParameters as? GameHostParameters
    }

    /// Event might occur when timer fires based on game parameters.
    var eventTimer = Timer()

    init(userId: String, gameHostParameters: GameHostParameters) {
        super.init(userId: userId, gameParameters: gameHostParameters)
        isHost = true
        self.eventTimer = Timer.scheduledTimer(timeInterval: TimeInterval(GameParameters.roundTime / 2),
                                               target: self,
                                               selector: #selector(generateEvent), userInfo: nil,
                                               repeats: false)
    }

    @objc
    func generateEvent() {
        guard let parameters = hostParameters else {
            return
        }

        let eventGenerator = EventGenerator(probabilityOfEvent: parameters.probabilityOfEvent)
        guard let event = eventGenerator.generate() else {
            return
        }
        // This will only make the event occur in the host
        // Modify to send the enum `EventType` through the network
        // Converting to actual event should be done through listener
        switch event {
        case .appreciationEvent:
            let event = AppreciationEvent()
            event.occur()
        }
    }

    /// Player who invokes this method becomes the host and joins the game.
    func createGame(username: String, avatar: PlayerAvatar) {
        network.createGame(completion: { gameId in
            self.joinGame(gameId: gameId, userName: username, avatar: avatar)
            NotificationCenter.default.post(name: .didCreateGame, object: nil)
        })
    }

    func startGame() {
        guard let gameId = gameId, let gameParameters = gameParameters else {
            return
        }
        
        // If usernames are not unique, do not start the game
        guard areUsernamesUnique() else {
            handleUnsuccessfulStart(error: .nonUniqueUsernames)
            return
        }
        
        // If player avatars are not unique, do not start the game
        guard areAvatarsUnique() else {
            handleUnsuccessfulStart(error: .nonUniqueAvatars)
            return
        }
        
        // Attempts to start game
        let difficultyLevel = gameParameters.difficultyLevel
        network.startGame(gameId: gameId, difficultyLevel: difficultyLevel, completion: { error in
            if let error = error {
                self.handleUnsuccessfulStart(error: error)
            }
        })
    }

    private func handleUnsuccessfulStart(error: StartGameError) {
        switch error {
        case .insufficientPlayers:
            NotificationCenter.default.post(name: .insufficientPlayers, object: nil)
        case .nonUniqueUsernames:
            NotificationCenter.default.post(name: .nonUniqueUsernames, object: nil)
        case .nonUniqueAvatars:
            NotificationCenter.default.post(name: .nonUniqueAvatars, object: nil)
        }
    }
    
    private func areUsernamesUnique() -> Bool {
        guard let players = game?.allPlayers else {
            return false
        }
        let usernames = players.map { $0.userName }
        return Set(usernames).count == game?.allPlayers.count
    }
    
    private func areAvatarsUnique() -> Bool {
        guard let players = game?.allPlayers else {
            return false
        }
        let avatars = players.map { $0.profileImage ?? .red }
        return Set(avatars).count == game?.allPlayers.count
    }
    
    func startRound() {
        // items and orders are generated and allocated by the host only
        let items = initialiseItems()
        initialiseOrders(items: items)
        initialisePackageItemsLimit()

        // network is notified to start round by the host only
        if let gameId = gameId, let roundNumber = game?.currentRoundNumber {
            network.startRound(gameId: gameId, roundNumber: roundNumber)
            // clear satisfaction levels stored in the cloud
            network.resetSatisfactionLevels(gameId: gameId)
        }
    }

    override func leaveGame(userId: String) {
        guard let gameId = gameId else {
            return
        }
        game = nil

        network.terminateGame(gameId: gameId, isGameEndedPrematurely: true)
    }

    override func attachNetworkListeners(userId: String, gameId: Int) {
        attachNonHostListeners(userId: userId, gameId: gameId)
        // to handle when everyone runs out of order
        self.network.attachOutOfOrdersListener(gameId: gameId, action: { numOfPlayersOutOfOrders in
            if numOfPlayersOutOfOrders == self.players.count {
                self.endRound() // the host will end the round when everyone runs out of orders
            }
        })
    }

    override func onTeamSatisfactionChange(satisfactionLevels: [Float]) {
        let numberOfPlayers = game?.allPlayers.count
        // only sum up the satisfaction levels if every player's is received
        if satisfactionLevels.count == numberOfPlayers {
            let sum = satisfactionLevels.reduce(0) { result, number in
                result + number
            }
            updateMoney(satisfactionLevel: Int(sum))
        }
        
        // checks the lose condition and ends the game if fulfilled
        if money < 0 {
            endGame()
        }
    }

    private func initialiseItems() -> [Item] {
        guard let numberOfPlayers = game?.numberOfPlayers, let gameId = gameId,
            let parameters = hostParameters else {
            return []
        }

        let categories = chooseCategories(numberOfPlayers: numberOfPlayers, parameters: parameters)
        // allocate items according to chosen categories
        let allocatedItems = allocateItems(numberOfPlayers: numberOfPlayers,
                                           parameters: parameters, categories: categories)

        gameCategories = categories

        // update other devices
        network.allocateItems(gameId: gameId, players: players)

        return allocatedItems
    }

    private func initialiseOrders(items: [Item]) {
        guard let players = game?.allPlayers, let gameId = gameId, let parameters = hostParameters else {
            return
        }

        allocateOrders(players: players, parameters: parameters, items: items)

        // update other devices
        network.allocateOrders(gameId: gameId, players: players)
    }

    private func chooseCategories(numberOfPlayers: Int, parameters: GameHostParameters) -> [Category] {
        let categoryGenerator = CategoryGenerator(numberOfPlayers: numberOfPlayers,
                                                  difficultyLevel: parameters.difficultyLevel,
                                                  numOfCategories: parameters.numOfCategories)
        return categoryGenerator.generateCategories()
    }

    private func allocateItems(numberOfPlayers: Int, parameters: GameHostParameters, categories: [Category]) -> [Item] {
        let itemsAllocator = ItemsAllocator(numberOfPlayers: numberOfPlayers,
                                            difficultyLevel: parameters.difficultyLevel,
                                            numOfPairsPerCategory: parameters.numOfPairsPerCategory)
        guard let players = game?.allPlayers else {
            return []
        }
        let allocatedItems = itemsAllocator.allocateItems(categories: categories, players: players)
        return allocatedItems
    }

    private func allocateOrders(players: [Player], parameters: GameHostParameters, items: [Item]) {
        let ordersAllocator = OrdersAllocator(difficultyLevel: parameters.difficultyLevel,
                                              maxNumOfItemsPerOrder: parameters.maxNumOfItemsPerOrder,
                                              numOfOrdersPerPlayer: parameters.numOfOrdersPerPlayer,
                                              probabilityOfSelectingOwnItem: parameters.probabilityOfSelectingOwnItem)
        ordersAllocator.allocateOrders(players: players, items: items)
    }

    private func initialisePackageItemsLimit() {
        guard let parameters = hostParameters, let gameId = gameId else {
            return
        }
        let allOrders = players.flatMap { $0.orders }
        let packageItemsLimitGenerator = PackageItemsLimitGenerator(orders: allOrders,
                                                                    probabilityOfHavingLimit:
                                                                        parameters.probabilityOfHavingPackageLimit)
        guard let packageItemsLimit = packageItemsLimitGenerator.generateItemsLimit() else {
            return
        }

        // update other devices
        network.setPackageItemsLimit(gameId: gameId, limit: packageItemsLimit)
    }

}
