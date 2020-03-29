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
    private var roundTimeInterval: Double = 120 // in seconds
    private var roundTimeLeft: Double = 0
    private var roundTimer = Timer()
    private var orderStartTimer = Timer()
    private var timeOutTimer = Timer()
    private var difficultyLevel: Float = 0
    private var dailyExpense: Int = 100

    var isHost: Bool = false
    var gameCategories: [Category] = []
    var satisfactionBar = SatisfactionBar(minSatisfaction: 0, maxSatisfaction: 100)
    var money: Int = 0

    // properties for model
    var game: Game?
    var houses: [House] {
        game?.houses ?? []
    }
    var players: [Player] {
        game?.allPlayers ?? []
    }
    var otherPlayers: [Player] {
        game?.allPlayers.filter { $0 != game?.player } ?? []
    }
    var playerPackages: [Package] {
        game?.packages ?? []
    }
    var playerItems: [Category: [Item]] {
        var itemsByCategory = [Category: [Item]]()
        game?.player.items.forEach {
            guard itemsByCategory[$0.category] != nil else {
                itemsByCategory[$0.category] = [$0]
                return
            }
            itemsByCategory[$0.category]?.append($0)
        }

        return itemsByCategory
    }

    // properties for network
    var network: Network = NetworkManager()
//    var userId: String? {
//        game?.player.userId // unique ID given by Firebase
//    }
    var userId: String?
    var gameId: Int? {
        game?.gameId
    }
    private var numOfSatisfactionLevelsReceived = 0

    init(userId: String) {
        self.userId = userId
        //game?.player.userId = userId

        addObservers()
    }

    /// Should only be called by host
    func startGame() {
        guard let gameId = gameId else {
            return
        }
        guard isHost else {
            return
        }
        network.startGame(gameId: gameId)
    }

    @objc
    func endGame() {
        guard let gameId = gameId else {
            return
        }
        network.terminateGame(gameId: gameId, isGameEndedPrematurely: false)
    }

    func startRound() {
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

    func pauseRound() {
        guard let gameId = gameId, let roundNumber = game?.currentRoundNumber else {
            return
        }
        pauseAllTimers()
        network.pauseRound(gameId: gameId, currentRound: roundNumber)
        // terminate game if game does not resume within 30 seconds
        timeOutTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(endGame),
                                            userInfo: nil, repeats: true)
    }

    func resumeRound() {
        guard let gameId = gameId, let roundNumber = game?.currentRoundNumber else {
            return
        }
        resumeAllTimers()
        network.resumeRound(gameId: gameId, currentRound: roundNumber)
    }

    @objc
    func updateTimeLeft() {
        roundTimeLeft -= 1
        if roundTimeLeft == 0 {
            endRound()
        }
    }

    @objc
    func endRound() {
        guard isHost, let gameId = gameId, let roundNumber = game?.currentRoundNumber else {
            return
        }
        network.terminateRound(gameId: gameId, roundNumber: roundNumber,
                               satisfactionLevel: satisfactionBar.currentSatisfaction)
        network.resetPlayersOutOfOrders(gameId: gameId)
    }

    /// Notifies view that there were changes made to some orders
    /// (e.g. insertion or deletion, timer updates) and calls #outOfOrders if list of orders is empty
    @objc
    func handleOrderChange(notification: Notification) {
        guard let houses = game?.houses else {
            return
        }
        let allOrders = houses.flatMap { $0.orders }
        if allOrders.isEmpty {
            outOfOrders()
        }
        NotificationCenter.default.post(name: .didChangeOrders, object: nil)
    }

    /// Updates the satisfaction bar and also removes the order that timed out and notifies view
    @objc
    func handleOrderTimeOut(notification: Notification) {
        guard let houses = game?.houses else {
            return
        }
        let allOrders = houses.flatMap { $0.orders }
        let timedOutOrders = allOrders.filter { $0.timeLeft <= 0 }
        for order in timedOutOrders {
            satisfactionBar.updateForTimeOut()
            removeOrder(order: order)
        }
        NotificationCenter.default.post(name: .didOrderTimeOut, object: nil)
    }

    @objc
    func handleSatisfactionBarChange(notification: Notification) {
        NotificationCenter.default.post(name: .didChangeSatisfactionBar, object: nil)
        if satisfactionBar.currentSatisfaction <= 0 {
            endRound()
        }
    }

    @objc
    func handleItemChange(notification: Notification) {
        NotificationCenter.default.post(name: .didChangeItems, object: nil)
    }

    @objc
    func handlePackageChange(notification: Notification) {
        NotificationCenter.default.post(name: .didChangePackages, object: nil)
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleItemChange),
                                               name: .didChangeItemsInModel, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePackageChange(notification:)),
                                               name: .didChangePackagesInModel, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleOrderChange(notification:)),
                                               name: .didOrderUpdateInModel, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleOrderTimeOut(notification:)),
                                               name: .didOrderTimeOutInModel, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleSatisfactionBarChange(notification:)),
                                               name: .didChangeCurrentSatisfaction, object: nil)
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

    private func getActiveOrders() -> [Order] {
        guard let houses = game?.houses else {
            return [Order]()
        }
        let allActiveOrders = houses.flatMap { $0.orders }.filter { $0.hasStarted }
        return allActiveOrders
    }

    /// Resumes all timers that were paused previously
    private func resumeAllTimers() {
        startRoundTimer()
        startOrders()
        resumeIndividualOrderTimers()
    }

    private func startRoundTimer() {
        self.roundTimer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                               selector: #selector(updateTimeLeft), userInfo: nil, repeats: true)
    }

    private func stopRoundTimer() {
        roundTimer.invalidate()
    }

    private func resumeIndividualOrderTimers() {
        let activeOrders = getActiveOrders()
        activeOrders.forEach { $0.resumeTimer() }
    }

    /// Pauses all timers that are active
    private func pauseAllTimers() {
        stopRoundTimer()
        stopOrders()
        stopIndividualOrderTimers()
    }

    private func stopIndividualOrderTimers() {
        let activeOrders = getActiveOrders()
        activeOrders.forEach { $0.stopTimer() }
    }

    private func stopOrders() {
        orderStartTimer.invalidate()
    }

}

extension GameControllerManager {

    /// Player who invokes this method becomes the host and joins the game.
    func createGame(userName: String) {
        network.createGame(completion: { gameId in
            self.joinGame(gameId: gameId, userName: userName)
            self.isHost = true
            NotificationCenter.default.post(name: .didCreateGame, object: nil)
        })
    }

    /// Player joins the game and with user defined username
    internal func joinGame(gameId: Int, userName: String) {
        guard let userId = self.userId else {
            return
        }
        
        network.joinGame(userId: userId, userName: userName, gameId: gameId, completion: { error in

            if let error = error {
                self.handleUnsuccessfulJoin(error: error)
            } else { // successfully joined the game
                self.handleSuccessfulJoin(userName: userName, userId: userId, gameId: gameId)
            }
        })
    }
    
    /// Enables the player to edit their username and profile image before the game starts
    func editUserInfo(username: String, profile: PlayerAvatar) {
        guard let gameId = gameId, let userId = userId else {
            return
        }
        network.editUserInfo(userId: userId, gameId: gameId,
                             username: username, profile: profile)
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

    private func handleSuccessfulJoin(userName: String, userId: String, gameId: Int) {
        let player = Player(userId: userId, userName: userName, profileImage: nil)
        self.game = GameManager(gameId: gameId, player: player)
        attachNetworkListeners(userId: userId, gameId: gameId)
        NotificationCenter.default.post(name: .didJoinGame, object: nil)
    }

    private func attachNetworkListeners(userId: String, gameId: Int) {
        self.network.attachPlayerJoinListener(gameId: gameId, action: self.onNewPlayerDidJoin)
        self.network.attachGameStatusListener(gameId: gameId, action: self.onGameStatusDidChange)
        self.network.attachTeamSatisfactionListener(gameId: gameId,
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
        // to handle when everyone runs out of order
        if isHost {
            self.network.attachOutOfOrdersListener(gameId: gameId, action: { numOfPlayersOutOfOrders in
                if numOfPlayersOutOfOrders == self.players.count {
                    self.endRound() // the host will end the round when everyone runs out of orders
                }
            })
        }
        // NotificationCenter.default.post(name: .didJoinGame, object: nil)
    }

    private func onNewPlayerDidJoin(players: [Player]) {
        game?.allPlayers = players
        NotificationCenter.default.post(name: .newPlayerDidJoin, object: nil)
    }

    // for game status listener
    private func onGameStatusDidChange(gameStatus: GameStatus) {
        let didStartGame = gameStatus.isGamePlaying && !gameStatus.isRoundPlaying && gameStatus.currentRound == 0
        let didEndGame = !gameStatus.isGamePlaying && !gameStatus.isRoundPlaying && gameStatus.currentRound != 0
        let didStartRound = gameStatus.isGamePlaying && gameStatus.isRoundPlaying
        let didEndRound = gameStatus.isGamePlaying && !gameStatus.isRoundPlaying && gameStatus.currentRound != 0
        let didEndGamePrematurely = gameStatus.isGameEndedPrematurely

        if didEndGamePrematurely {
            handleGameEnd()
            NotificationCenter.default.post(name: .didEndGamePrematurely, object: nil)
        } else if didStartGame {
            NotificationCenter.default.post(name: .didStartGame, object: nil)
        } else if didEndGame {
            handleGameEnd()
            NotificationCenter.default.post(name: .didEndGame, object: nil)
        } else if didStartRound {
            handleRoundStart()
            NotificationCenter.default.post(name: .didStartRound, object: nil)
            game?.incrementRoundNumber()
        } else if didEndRound {
            handleRoundEnd()
            NotificationCenter.default.post(name: .didEndRound, object: nil)
        }
        // for resumeRound, need to invalidate the timeOutTimer
    }

    private func startOrders() {
        // Start random orders at regular intervals
        orderStartTimer = Timer.scheduledTimer(timeInterval: 15, target: self,
                                               selector: #selector(startRandomOrder), userInfo: nil,
                                               repeats: true)
    }

    @objc
    func startRandomOrder() {
        guard let houses = game?.houses else {
            return
        }
        let allNewOrders = houses.flatMap { $0.orders }.filter { !$0.hasStarted }
        if allNewOrders.isEmpty {
            outOfOrders()
            return
        }
        let indexRange = 0...(allNewOrders.count - 1)
        let randomIndex = Int.random(in: indexRange)
        let randomOrder = allNewOrders[randomIndex]
        randomOrder.startOrder()
    }

    private func onTeamSatisfactionChange(satisfactionLevel: Int) {
        money += satisfactionLevel * 2 // arbitrary translation rate; to change next time
        numOfSatisfactionLevelsReceived += 1
        NotificationCenter.default.post(name: .didChangeMoney, object: nil)
        
        if numOfSatisfactionLevelsReceived == players.count - 1 {
            money -= dailyExpense
            numOfSatisfactionLevelsReceived = 0 // reset
            NotificationCenter.default.post(name: .didChangeMoney, object: nil)
        }

        guard isHost else {
            return
        }

        // the host checks the lose condition and ends the game if fulfilled
        if money < 0 {
            endGame()
        }
    }

    /// Assigns orders to houses and sets the houses in Game to this new list of houses
    private func initialiseHouses(with orders: [Order]) {
        guard let numOfHouses = game?.defaultNumberOfHouses else {
            return
        }
        var splitOrders = [[Order]]()
        for _ in 1...numOfHouses {
            splitOrders.append([])
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

    private func handleGameEnd() {
        game = nil
        orderStartTimer = Timer()
        difficultyLevel = 0
        dailyExpense = 100

        isHost = false
        gameCategories = []
        satisfactionBar = SatisfactionBar(minSatisfaction: 0, maxSatisfaction: 100)
        money = 0
    }

    private func handleRoundEnd() {
        game?.resetForNewRound()
        difficultyLevel += 0.1
    }

    private func handleRoundStart() {
        satisfactionBar.reset()
        roundTimeLeft = roundTimeInterval
        startRoundTimer()
        startOrders()
    }

    private func generateDummyUserName() -> String {
        let random = Int.random(in: 1...100)
        return "Player " + String(players.count + random)
    }

    /// To inform the network that this player has run out of orders
    private func outOfOrders() {
        guard let gameId = gameId, let userId = userId else {
            return
        }
        network.outOfOrders(userId: userId, gameId: gameId)
    }
}

extension GameControllerManager {

    var openedPackage: Package? {
        game?.currentlyOpenPackage
    }

    func addNewPackage() {
        game?.addNewPackage()
    }

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

    func retrieveActiveOrders(for house: House) -> [Order] {
        guard let orders = game?.retrieveOrders(for: house) else {
            return []
        }
        return orders.filter { $0.hasStarted }
    }

    func retrieveItemsFromOpenPackage() -> [Item] {
        game?.currentlyOpenPackage?.items ?? []
    }
    
    private func removeOrder(order: Order) {
        game?.removeOrder(order: order)
    }

    private func updateGameProperties(order: Order, isCorrect: Bool) {
        satisfactionBar.update(order: order, isCorrect: isCorrect)
    }
}
