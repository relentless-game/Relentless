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

    var hostNetwork: HostNetwork? {
        network as? HostNetwork
    }

    var itemsGenerator: GameItemGenerator?
    var itemsAllocator: GameItemsAllocator?
    var ordersAllocator: GameOrdersAllocator?

    private var demoMode: Bool

    init(userId: String, demoMode: Bool) {
        self.demoMode = demoMode
        super.init(userId: userId)
        self.gameParameters = getParameters()
        self.network = HostNetworkManager()
        self.isHost = true
    }

    func initialiseGeneratorAndAllocators() {
        guard let parameters = hostParameters else {
            return
        }

        itemsGenerator = ItemGenerator(numberOfPlayers: players.count,
                                       numOfGroupsPerCategory: parameters.numOfGroupsPerCategory,
                                       itemSpecifications: super.itemSpecifications)

        itemsAllocator = ItemsAllocator()

        let probOfSelectingAssembledItem =
            parameters.probOfSelectingAssembledItem(numberOfPlayers: players.count)
        ordersAllocator = OrdersAllocator(maxNumOfItemsPerOrder: parameters.maxNumOfItemsPerOrder,
                                          numOfOrdersPerPlayer: parameters.numOfOrdersPerPlayer,
                                          probabilityOfSelectingAssembledItem: probOfSelectingAssembledItem,
                                          timeForEachItem: parameters.timeForEachItem)
    }

    /// Player who invokes this method becomes the host and joins the game.
    func createGame(username: String, avatar: PlayerAvatar) {
        guard let hostNetwork = hostNetwork else {
            return
        }
        hostNetwork.createGame(completion: { gameId in
            self.joinGame(gameId: gameId, userName: username, avatar: avatar)
            self.initialiseNumberOfPlayersRange(gameId: gameId)
            NotificationCenter.default.post(name: .didCreateGame, object: nil)
        })
    }

    func startGame() {
        guard let gameId = gameId else {
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
        guard let configValues = getLocalConfigValues() else {
            // If config values are nil, all players should just use default values to ensure synchronisation
            let defaultConfigValues = LocalConfigValues(filePath: "DefaultGameParameters")
            self.gameParameters = GameHostParametersParser(configValues: defaultConfigValues).parse()
            startGameInNetwork(gameId: gameId, configValues: defaultConfigValues)
            return
        }

        startGameInNetwork(gameId: gameId, configValues: configValues)
    }

    private func initialiseNumberOfPlayersRange(gameId: Int) {
        guard let parameters = hostParameters, let hostNetwork = hostNetwork else {
            return
        }
        let minPlayers = parameters.numOfPlayersRange.lowerBound
        let maxPlayers = parameters.numOfPlayersRange.upperBound
        hostNetwork.initialiseNumberOfPlayersRange(gameId: gameId, min: minPlayers, max: maxPlayers)
    }

    private func startGameInNetwork(gameId: Int, configValues: LocalConfigValues) {
        guard let hostNetwork = hostNetwork else {
            return
        }
        hostNetwork.startGame(gameId: gameId, configValues: configValues, completion: { error in
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
        guard let gameId = self.gameId, let roundNumber = game?.currentRoundNumber, let hostNetwork = hostNetwork else {
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
        hostNetwork.startRound(gameId: gameId, roundNumber: roundNumber)
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

    private func getParameters() -> GameHostParameters? {
        if demoMode {
            return GameHostParametersParser(configValues:
                LocalConfigValues(filePath: "DemoGameParameters")).parse()
        } else {
            return ConfigNetworkManager.getInstance().fetchGameHostParameters()
        }
    }

    private func getLocalConfigValues() -> LocalConfigValues? {
        if demoMode {
            return LocalConfigValues(filePath: "DemoGameParameters")
        } else {
            return ConfigNetworkManager.getInstance().fetchLocalConfigValues()
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
        let mappings = super.itemSpecifications.availableGroupsOfItems
        let categoryGenerator = CategoryGenerator(numberOfPlayers: numberOfPlayers,
                                                  difficultyLevel: parameters.difficultyLevel,
                                                  numOfCategories: parameters.numOfCategories,
                                                  categoryToGroupsMapping: mappings)
        return categoryGenerator.generateCategories()
    }

    private func initialisePackageItemsLimit() -> Int? {
        guard let parameters = hostParameters else {
            return nil
        }
        let allOrders = players.flatMap { $0.orders }
        let probability = parameters.probOfHavingPackageLimit
        let packageItemsLimitGenerator = PackageItemsLimitGenerator(orders: allOrders,
                                                                    probabilityOfHavingLimit: probability)
        return packageItemsLimitGenerator.generateItemsLimit()
    }

    /// Sends the items, orders, package limit and round item specifications to all players through the network
    private func updateOtherDevices(gameId: Int, packageItemsLimit: Int?,
                                    roundItemSpecifications: RoundItemSpecifications) {
        guard let hostNetwork = hostNetwork else {
            return
        }
        hostNetwork.allocateItems(gameId: gameId, players: players)
        hostNetwork.allocateOrders(gameId: gameId, players: players)
        if let nonNilPackageItemsLimit = packageItemsLimit {
            hostNetwork.setPackageItemsLimit(gameId: gameId, limit: nonNilPackageItemsLimit)
        }
        hostNetwork.broadcastRoundItemSpecification(gameId: gameId, roundItemSpecification: roundItemSpecifications)
    }

    private func constructRoundItemSpecifications(items: [Item]) -> RoundItemSpecifications {
        let assembledItems = items.compactMap { $0 as? AssembledItem }
        let assembledItemCategories = getAssembledItemCategories(assembledItems: assembledItems)
        let specifications =
            RoundItemSpecifications(partsToAssembledItemCategoryMapping: assembledItemCategories)
        return specifications
    }

    /// Constructs the mapping between the assembled item's category and the categories of the parts it is made up of
    private func getAssembledItemCategories(assembledItems: [AssembledItem]) -> [[Category]: Category] {
        var assembledItemCategories = [[Category]: Category]()
        var allAssembledItems = Set<AssembledItem>()
        for assembledItem in assembledItems {
            let embeddedAssembledItems = getAllAssembledItems(assembledItem: assembledItem)
            allAssembledItems = allAssembledItems.union(embeddedAssembledItems)
        }
        for assembledItem in allAssembledItems {
            let category = assembledItem.category
            var categoriesOfParts = [Category]()
            for part in assembledItem.parts {
//                if part as? AssembledItem == nil {
//                    categoriesOfParts.append(part.category)
//                    continue
//                }
//                guard let requiredCategories =
//                itemSpecifications.assembledItemToPartsCategoryMapping[part.category] else {
//                    continue
//                }
                categoriesOfParts.append(part.category)
            }
            assembledItemCategories[categoriesOfParts.sorted()] = category
        }
        return assembledItemCategories
    }

    private func getAllAssembledItems(assembledItem: AssembledItem) -> Set<AssembledItem> {
        var allAssembledItems = Set<AssembledItem>()
        allAssembledItems.insert(assembledItem)
        for part in assembledItem.parts {
            guard let assembledItem = part as? AssembledItem else {
                continue
            }
            allAssembledItems = allAssembledItems.union(getAllAssembledItems(assembledItem: assembledItem))
        }
        return allAssembledItems
    }
}
