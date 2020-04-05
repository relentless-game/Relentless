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
    private var roundTimeLeft: Int = 0
    private var roundTimer = Timer()
    private var orderStartTimer = Timer()

    var gameCategories: [Category] = []
    var satisfactionBar = SatisfactionBar(minSatisfaction: GameParameters.minSatisfaction,
                                          maxSatisfaction: GameParameters.maxSatisfaction)
    var money: Int = 0
    var isHost: Bool
    var gameParameters: GameParameters?

    // properties for model
    var game: Game?
    var houses: [House] {
        game?.houses ?? []
    }
    var player: Player? {
        game?.player
    }
    var players: [Player] {
        game?.allPlayers ?? []
    }
    var otherPlayers: [Player] {
        game?.allPlayers.filter { $0.userId != game?.player.userId } ?? []
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
    var network: Network = NetworkManager(numOfPlayersRange: GameParameters.numOfPlayersRange)
//    var userId: String? {
//        game?.player.userId // unique ID given by Firebase
//    }
    var userId: String?
    var gameId: Int? {
        game?.gameId
    }
    var gameStatus: GameStatus? // added this for the background pause feature

    // for pausing the game
    var pauseTimer: Timer?
    var pauseCountDown: Int = 30

    // properties for local storage
    var localStorage: LocalStorage = LocalStorageManager()
    
    init(userId: String, gameParameters: GameParameters?) {
        self.userId = userId
        self.gameParameters = gameParameters
        // game?.player.userId = userId
        self.isHost = false
        addObservers()
    }

    func endGame() {
        guard let gameId = gameId else {
            return
        }
        network.terminateGame(gameId: gameId, isGameEndedPrematurely: false)
    }

    func pauseRound() {
        guard let gameId = gameId, var newGameStatus = gameStatus else {
            return
        }

        newGameStatus.numberOfPlayersPaused += 1
        newGameStatus.isResumed = false
        gameStatus = newGameStatus

        let numberOfPlayersPaused = newGameStatus.numberOfPlayersPaused
        if numberOfPlayersPaused == 1 {
            let timer = Timer(timeInterval: 1.0, target: self, selector: #selector(decrementPauseTimer),
                              userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: .default)
            pauseTimer = timer
        }
        
        network.updateGameStatus(gameId: gameId, gameStatus: newGameStatus)
    }
    
    @objc
    private func decrementPauseTimer() {
        guard let gameId = gameId else {
            return
        }
        pauseCountDown -= 1
        network.updatePauseCountDown(gameId: gameId, countDown: pauseCountDown)
        
        // end the game if count down reaches 0
        if pauseCountDown == 0 {
            endGame()
        }
    }

    func resumeRound() {
        guard let gameId = gameId, let roundNumber = game?.currentRoundNumber, var newGameStatus = gameStatus else {
            return
        }
        
        newGameStatus.numberOfPlayersPaused -= 1
        gameStatus = newGameStatus
        
        // only resume if all players are back
        let areAllPlayersBack = newGameStatus.numberOfPlayersPaused == 0
        if areAllPlayersBack {
            network.resumeRound(gameId: gameId, currentRound: roundNumber)
        } else {
            network.updateGameStatus(gameId: gameId, gameStatus: newGameStatus)
        }
    }

    func getExistingScores() throws -> [ScoreRecord] {
        try localStorage.getExistingScores()
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
        guard let gameId = gameId, let roundNumber = game?.currentRoundNumber else {
            return
        }
        network.terminateRound(gameId: gameId, roundNumber: roundNumber)
        network.resetPlayersOutOfOrders(gameId: gameId)
    }

    /// Notifies view that there were changes made to some orders
    /// (e.g. insertion or deletion, timer updates) and calls #outOfOrders if list of orders is empty
    @objc
    func handleOrderChange(notification: Notification) {
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
            updateSatisfaction(order: order, package: nil, isCorrect: false)
            removeOrder(order: order)
        }
        NotificationCenter.default.post(name: .didOrderTimeOut, object: nil)
    }

    @objc
    func handleSatisfactionBarChange(notification: Notification) {
        NotificationCenter.default.post(name: .didChangeSatisfactionBar, object: nil)
        if satisfactionBar.currentSatisfaction == 0 {
            satisfactionBar.penalise()
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

    @objc
    func handleItemLimitReached(notification: Notification) {
        NotificationCenter.default.post(name: .didItemLimitReached, object: nil)
    }

    @objc
    func handleChangeOfOpenPackage(notification: Notification) {
        NotificationCenter.default.post(name: .didChangeOpenPackage, object: nil)
    }

    @objc
    func handleOrderTimeLeftChange(notification: Notification) {
        satisfactionBar.decrementWithTime()
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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleItemLimitReached(notification:)),
                                               name: .didItemLimitReachedInModel, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleChangeOfOpenPackage(notification:)),
                                               name: .didChangeOpenPackageInModel, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleOrderTimeLeftChange(notification:)),
                                               name: .didOrderTimeUpdateInModel, object: nil)
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

    /// Player joins the game and with user defined username
    internal func joinGame(gameId: Int, userName: String, avatar: PlayerAvatar) {
        guard let userId = self.userId else {
            return
        }
        
        network.joinGame(userId: userId, userName: userName, avatar: avatar, gameId: gameId, completion: { error in

            if let error = error {
                self.handleUnsuccessfulJoin(error: error)
            } else { // successfully joined the game
                self.handleSuccessfulJoin(userName: userName, userId: userId, avatar: avatar, gameId: gameId)
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

    @objc
    func leaveGame(userId: String) {
        guard let gameId = gameId else {
            return
        }
        game = nil
        network.quitGame(userId: userId, gameId: gameId)
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

    private func handleSuccessfulJoin(userName: String, userId: String, avatar: PlayerAvatar, gameId: Int) {
        let player = Player(userId: userId, userName: userName, profileImage: avatar)
        self.game = GameManager(gameId: gameId, player: player)
        attachNetworkListeners(userId: userId, gameId: gameId)
        NotificationCenter.default.post(name: .didJoinGame, object: nil)
    }

    @objc
    internal func attachNetworkListeners(userId: String, gameId: Int) {
        attachNonHostListeners(userId: userId, gameId: gameId)
        // The host should not have this listener
        self.network.attachDifficultyLevelListener(gameId: gameId, action: { difficultyLevel in
            self.gameParameters = GameParameters(difficultyLevel: difficultyLevel)
        })
    }

    internal func attachNonHostListeners(userId: String, gameId: Int) {
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
        self.network.attachPauseCountDownListener(gameId: gameId, action: self.onPauseCountDownDidChange)
        self.network.attachPackageItemsLimitListener(gameId: gameId, action: { limit in
            self.game?.packageItemsLimit = limit
        })
    }
    
    private func onPauseCountDownDidChange(countdown: Int) {
        pauseCountDown = countdown
        NotificationCenter.default.post(name: .didUpdateCountDown, object: nil)
    }

    private func onNewPlayerDidJoin(players: [Player]) {
        game?.allPlayers = players
        // change the player itself
        for player in players where player.userId == self.userId {
            game?.player.userName = player.userName
            game?.player.profileImage = player.profileImage
        }
        NotificationCenter.default.post(name: .newPlayerDidJoin, object: nil)
    }

    // for game status listener
    private func onGameStatusDidChange(gameStatus: GameStatus) {
        // update game status
        self.gameStatus = gameStatus
        
        let didStartGame = gameStatus.isGamePlaying && !gameStatus.isRoundPlaying && gameStatus.currentRound == 0
            && gameStatus.numberOfPlayersPaused == 0
        let didEndGame = !gameStatus.isGamePlaying && !gameStatus.isRoundPlaying && gameStatus.currentRound != 0 
        let didStartRound = gameStatus.isGamePlaying && gameStatus.isRoundPlaying &&
            gameStatus.numberOfPlayersPaused == 0 && !gameStatus.isResumed
        let didEndRound = gameStatus.isGamePlaying && !gameStatus.isRoundPlaying && gameStatus.currentRound != 0
        let didEndGamePrematurely = gameStatus.isGameEndedPrematurely
        let didPauseRound = gameStatus.isRoundPlaying && gameStatus.numberOfPlayersPaused != 0
        let didResumeRound = gameStatus.isResumed && gameStatus.isRoundPlaying
        
        if didEndGamePrematurely {
            handleGameEnd()
            NotificationCenter.default.post(name: .didEndGamePrematurely, object: nil)
        } else if didStartGame {
            NotificationCenter.default.post(name: .didStartGame, object: nil)
        } else if didEndGame /*|| didRunOutPauseTime*/ {
            handleGameEnd()
            NotificationCenter.default.post(name: .didEndGame, object: nil)
        } else if didStartRound {
            handleRoundStart()
            NotificationCenter.default.post(name: .didStartRound, object: nil)
            game?.incrementRoundNumber()
        } else if didEndRound {
            handleRoundEnd()
            NotificationCenter.default.post(name: .didEndRound, object: nil)
        } else if didPauseRound {
            pauseAllTimers()
            NotificationCenter.default.post(name: .didPauseRound, object: nil)
        } else if didResumeRound {
            resumeAllTimers()
            pauseTimer?.invalidate()
            resumeAllTimers()
            NotificationCenter.default.post(name: .didResumeRound, object: nil)
        }
    }

    private func startOrders() {
        startRandomOrder()
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
            return
        }
        let indexRange = 0...(allNewOrders.count - 1)
        let randomIndex = Int.random(in: indexRange)
        let randomOrder = allNewOrders[randomIndex]
        randomOrder.startOrder()
    }

    @objc
    internal func onTeamSatisfactionChange(satisfactionLevels: [Float]) {
        let numberOfPlayers = game?.allPlayers.count
        // only sum up the satisfaction levels if every player's is received
        if satisfactionLevels.count == numberOfPlayers {
            let sum = satisfactionLevels.reduce(0) { result, number in
                result + number
            }
            updateMoney(satisfactionLevel: Int(sum))
        }
    }

    internal func updateMoney(satisfactionLevel: Int) {
        money += satisfactionLevel * GameParameters.satisfactionToMoneyTranslation
        money -= GameParameters.dailyExpense
        NotificationCenter.default.post(name: .didChangeMoney, object: nil)
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
            let satisfactionFactor = Float.random(in: GameParameters.houseSatisfactionFactorRange)
            for order in orders {
                let originalTimeLimit = order.timeLimit
                order.timeLimit = Int(Float(originalTimeLimit) * satisfactionFactor)
            }
            houses.append(House(orders: Set(orders), satisfactionFactor: satisfactionFactor))
        }
        game?.houses = houses
    }

    private func handleGameEnd() {
        updateScore()
        resetAllAttributes()
        NotificationCenter.default.post(name: .didEndGame, object: nil)
    }

    private func updateScore() {
        guard let score = game?.currentRoundNumber else {
            return
        }
        let userNamesOfPlayers = players.map { $0.userName }
        localStorage.updateScoreBoard(with: ScoreRecord(score: score,
                                                        userNamesOfPlayers: userNamesOfPlayers, isLatestEntry: true))
    }

    private func resetAllAttributes() {
        guard let parameters = gameParameters else {
            return
        }
        game = nil
        orderStartTimer = Timer()
        parameters.reset() // reset game parameters

        gameCategories = []
        satisfactionBar = SatisfactionBar(minSatisfaction: 0, maxSatisfaction: 100)
        money = 0
    }

    private func handleRoundEnd() {
        guard let parameters = gameParameters else {
            return
        }
        game?.resetForNewRound()
        parameters.incrementDifficulty()
        
        guard let gameId = gameId, let userId = userId else {
            return
        }
        let satisfaction = satisfactionBar.currentSatisfaction
        network.updateIndividualSatisfactionLevel(gameId: gameId, userId: userId, satisfactionLevel: satisfaction)
    }

    private func handleRoundStart() {
        satisfactionBar.reset()
        roundTimeLeft = GameParameters.roundTime
        startRoundTimer()
        startOrders()
    }
    
    private func generateDummyUserName() -> String {
        let random = Int.random(in: 1...100)
        return "Player " + String(players.count + random)
    }

    /// To inform the network that this player has run out of orders
    @objc private func outOfOrders() {
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
        updateSatisfaction(order: order, package: package, isCorrect: isCorrect)
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

    func retrieveOpenPackage() -> Package? {
        game?.currentlyOpenPackage
    }
    
    private func removeOrder(order: Order) {
        game?.removeOrder(order: order)
        let hasNoMoreOrders = houses.flatMap { $0.orders }.isEmpty
        if hasNoMoreOrders {
            // wait for view to segue back to packing screen
            Timer.scheduledTimer(timeInterval: 1,
                                 target: self,
                                 selector: #selector(outOfOrders),
                                 userInfo: nil, repeats: false)
        }
    }

    func constructAssembledItem(parts: [Part]) throws {
        try game?.constructAssembledItem(parts: parts)
    }

    private func updateSatisfaction(order: Order, package: Package?, isCorrect: Bool) {
        satisfactionBar.update(order: order, package: package, isCorrect: isCorrect)
    }
}
