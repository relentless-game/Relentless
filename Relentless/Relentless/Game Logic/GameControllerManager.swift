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
    internal var roundTimeLeft: Int = 0
    internal var roundTimer = Timer()
    internal var orderStartTimer = Timer()

    var gameCategories: [Category] = []
    var satisfactionBar: SatisfactionBar
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
    
    var itemSpecifications: ItemSpecifications
    
    init(userId: String, gameParameters: GameParameters?) {
        self.userId = userId
        self.gameParameters = gameParameters
        self.isHost = false
        self.itemSpecifications = ItemSpecificationsParser.parse()
        self.satisfactionBar = SatisfactionBar(range: GameParameters.satisfactionRange)
        addObservers()
    }

    internal func addObservers() {
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

    internal func updateMoney(satisfactionLevel: Int) {
        guard let parameters = gameParameters else {
            return
        }
        money += satisfactionLevel * parameters.satisfactionToMoneyTranslation
        money -= parameters.dailyExpense
        NotificationCenter.default.post(name: .didChangeMoney, object: nil)
    }

    internal func handleGameEnd() {
        updateScore()
        resetAllAttributes()
        NotificationCenter.default.post(name: .didEndGame, object: nil)
    }

    internal func updateScore() {
        guard let score = game?.currentRoundNumber else {
            return
        }
        let userNamesOfPlayers = players.map { $0.userName }
        localStorage.updateScoreBoard(with: ScoreRecord(score: score,
                                                        userNamesOfPlayers: userNamesOfPlayers, isLatestEntry: true))
    }

    internal func resetAllAttributes() {
        guard let parameters = gameParameters else {
            return
        }
        game = nil
        orderStartTimer = Timer()
        parameters.reset() // reset game parameters

        gameCategories = []
        satisfactionBar = SatisfactionBar(range: GameParameters.satisfactionRange)
        money = 0
    }

    internal func handleRoundEnd() {
        guard let parameters = gameParameters else {
            return
        }
        parameters.incrementDifficulty()

        guard let gameId = gameId, let userId = userId else {
            return
        }
        let satisfaction = satisfactionBar.currentSatisfaction
        network.updateIndividualSatisfactionLevel(gameId: gameId, userId: userId, satisfactionLevel: satisfaction)
    }

    internal func startOrders() {
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
    func updateTimeLeft() {
        roundTimeLeft -= 1
        if roundTimeLeft == 0 {
            endRound()
        }
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
        guard let parameters = gameParameters else {
            return
        }
        NotificationCenter.default.post(name: .didChangeSatisfactionBar, object: nil)
        if satisfactionBar.currentSatisfaction == 0 {
            satisfactionBar.penalise(penalty: parameters.satisfactionRunOutPenalty)
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
        guard let parameters = gameParameters else {
            return
        }
        satisfactionBar.decrementWithTime(amount: parameters.satisfactionUnitDecrease)
        NotificationCenter.default.post(name: .didChangeOrders, object: nil)
    }

    internal func updateSatisfaction(order: Order, package: Package?, isCorrect: Bool) {
        guard let parameters = gameParameters else {
            return
        }
        let expression: (([String: Float]) -> Float?)?
        if isCorrect && package != nil {
            expression = parameters.correctPackageSatisfactionChangeExpression
        } else {
            expression = parameters.wrongPackageSatisfactionChangeExpression
        }
        satisfactionBar.update(order: order, package: package, isCorrect: isCorrect, expression: expression)
    }

    internal func getActiveOrders() -> [Order] {
        guard let houses = game?.houses else {
            return [Order]()
        }
        let allActiveOrders = houses.flatMap { $0.orders }.filter { $0.hasStarted }
        return allActiveOrders
    }

    /// Resumes all timers that were paused previously
    internal func resumeAllTimers() {
        startRoundTimer()
        startOrders()
        resumeIndividualOrderTimers()
    }

    internal func startRoundTimer() {
        self.roundTimer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                               selector: #selector(updateTimeLeft), userInfo: nil, repeats: true)
    }

    internal func stopRoundTimer() {
        roundTimer.invalidate()
    }

    internal func resumeIndividualOrderTimers() {
        let activeOrders = getActiveOrders()
        activeOrders.forEach { $0.resumeTimer() }
    }

    /// Pauses all timers that are active
    internal func pauseAllTimers() {
        stopRoundTimer()
        stopOrders()
        stopIndividualOrderTimers()
    }

    internal func stopIndividualOrderTimers() {
        let activeOrders = getActiveOrders()
        activeOrders.forEach { $0.stopTimer() }
    }

    internal func stopOrders() {
        orderStartTimer.invalidate()
    }

    internal func handleRoundStart() {
        guard let parameters = gameParameters else {
            return
        }
        game?.resetForNewRound()
        satisfactionBar.reset()
        roundTimeLeft = parameters.roundTime
        startRoundTimer()
        startOrders()
    }

}

extension GameControllerManager {
    func getExistingScores() throws -> [ScoreRecord] {
        try localStorage.getExistingScores()
    }
}
