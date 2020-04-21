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

    var itemsGenerator: GameItemGenerator?
    var itemsAllocator: GameItemsAllocator?
    var ordersAllocator: GameOrdersAllocator?

    /// Event might occur when timer fires based on game parameters.
    var eventTimer = Timer()

    init(userId: String, gameHostParameters: GameHostParameters) {
        super.init(userId: userId, gameParameters: gameHostParameters)
        isHost = true
        self.eventTimer = Timer.scheduledTimer(timeInterval: TimeInterval(gameHostParameters.roundTime / 2),
                                               target: self,
                                               selector: #selector(generateEvent), userInfo: nil,
                                               repeats: false)
    }

    func initialiseGeneratorAndAllocators() {
        guard let parameters = hostParameters else {
            return
        }
        itemsGenerator = ItemGenerator(numberOfPlayers: players.count,
                                       difficultyLevel: parameters.difficultyLevel,
                                       numOfPairsPerCategory: parameters.numOfGroupsPerCategory,
                                       itemSpecifications: super.itemSpecifications)
        itemsAllocator = ItemsAllocator()
        ordersAllocator = OrdersAllocator(difficultyLevel: parameters.difficultyLevel,
                                          maxNumOfItemsPerOrder: parameters.maxNumOfItemsPerOrder,
                                          numOfOrdersPerPlayer: parameters.numOfOrdersPerPlayer,
                                          probabilityOfSelectingOwnItem: parameters.probOfSelectingOwnItem,
                                          timeForEachItem: parameters.timeForEachItem)
    }

    @objc
    func generateEvent() {
        guard let parameters = hostParameters else {
            return
        }

        let eventGenerator = EventGenerator(probabilityOfEvent: parameters.probOfEvent)
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
            self.initialiseGeneratorAndAllocators()
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
        let avatars = players.map { $0.profileImage }
        return Set(avatars).count == game?.allPlayers.count
    }
    
    func startRound() {
        guard let gameId = self.gameId, let roundNumber = game?.currentRoundNumber else {
            return
        }
        // items and orders are generated and allocated by the host only
        let generatedItems = initialiseItems()
        let inventoryItems = generatedItems.0
        let orderItems = generatedItems.1

        itemsAllocator?.allocateItems(inventoryItems: inventoryItems, to: players)
        ordersAllocator?.allocateOrders(orderItems: orderItems, to: players)

        let packageLimit = initialisePackageItemsLimit()

        var allItems = Set(inventoryItems)
        allItems = allItems.union(Set(orderItems))
        let roundItemSpecifications = constructRoundItemSpecifications(items: Array(allItems))
        // Update all other devices with the allocated items
        updateOtherDevices(gameId: gameId, packageItemsLimit: packageLimit,
                           roundItemSpecifications: roundItemSpecifications)

        // network is notified to start round by the host only
        network.startRound(gameId: gameId, roundNumber: roundNumber)
        // clear satisfaction levels stored in the cloud
        network.resetSatisfactionLevels(gameId: gameId)
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

    /// Returns an array of inventory items and order items
    private func initialiseItems() -> ([Item], [Item]) {
        guard let parameters = hostParameters, let itemsGenerator = self.itemsGenerator else {
            return ([], [])
        }
        let numberOfPlayers = players.count

        let categories = chooseCategories(numberOfPlayers: numberOfPlayers, parameters: parameters)
        // allocate items according to chosen categories

        let generatedItems = itemsGenerator.generate(categories: categories)

        gameCategories = categories

        return generatedItems
    }

    private func chooseCategories(numberOfPlayers: Int, parameters: GameHostParameters) -> [Category] {
        let categoryGenerator = CategoryGenerator(numberOfPlayers: numberOfPlayers,
                                                  difficultyLevel: parameters.difficultyLevel,
                                                  numOfCategories: parameters.numOfCategories,
                                                  categoryToGroupsMapping: super.itemSpecifications.availableGroupsOfItems)
        return categoryGenerator.generateCategories()
    }

    private func initialisePackageItemsLimit() -> Int? {
        guard let parameters = hostParameters else {
            return nil
        }
        let allOrders = players.flatMap { $0.orders }
        let packageItemsLimitGenerator = PackageItemsLimitGenerator(orders: allOrders,
                                                                    probabilityOfHavingLimit: parameters.probOfHavingPackageLimit)
        return packageItemsLimitGenerator.generateItemsLimit()
    }

    /// Sends the items, orders, package limit and round item specifications to all players through the network
    private func updateOtherDevices(gameId: Int, packageItemsLimit: Int?,
                                    roundItemSpecifications: RoundItemSpecifications) {
        network.allocateItems(gameId: gameId, players: players)
        network.allocateOrders(gameId: gameId, players: players)
        if let nonNilPackageItemsLimit = packageItemsLimit {
            network.setPackageItemsLimit(gameId: gameId, limit: nonNilPackageItemsLimit)
        }
        network.broadcastRoundItemSpecification(gameId: gameId, roundItemSpecification: roundItemSpecifications)
    }

    private func constructRoundItemSpecifications(items: [Item]) -> RoundItemSpecifications {
        let assembledItems = items.compactMap { $0 as? AssembledItem }
        let assembledItemCategories = getAssembledItemCategories(assembledItems: assembledItems)
        let specifications = RoundItemSpecifications(partsToAssembledItemCategoryMapping:
            assembledItemCategories)
        return specifications
    }

    /// Constructs the mapping between the assembled item's category and the categories of the parts it is made up of
    private func getAssembledItemCategories(assembledItems: [AssembledItem]) -> [[Category]: Category] {
        var assembledItemCategories = [[Category]: Category]()
        for assembledItem in assembledItems {
            let category = assembledItem.category
            let categoriesOfParts = assembledItem.parts.map { $0.category }
            if assembledItemCategories[categoriesOfParts] != nil {
                continue
            }
            assembledItemCategories[categoriesOfParts] = category
        }
        return assembledItemCategories
    }
}
