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

    init(userId: String, gameHostParameters: GameHostParameters) {
        super.init(userId: userId, gameParameters: gameHostParameters)
        isHost = true
    }

    /// Player who invokes this method becomes the host and joins the game.
    func createGame(username: String) {
        network.createGame(completion: { gameId in
            self.joinGame(gameId: gameId, userName: username)
            NotificationCenter.default.post(name: .didCreateGame, object: nil)
        })
    }

    func startGame() {
        guard let gameId = gameId else {
            return
        }
        network.startGame(gameId: gameId)
    }

    func startRound() {
        // items and orders are generated and allocated by the host only
        initialiseItems()
        initialiseOrders()
        // network is notified to start round by the host only
        if let gameId = gameId, let roundNumber = game?.currentRoundNumber {
            network.startRound(gameId: gameId, roundNumber: roundNumber)
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

    override func onTeamSatisfactionChange(satisfactionLevel: Int) {
        updateSatisfaction(satisfactionLevel: satisfactionLevel)
        
        // checks the lose condition and ends the game if fulfilled
        if money < 0 {
            endGame()
        }
    }

    private func initialiseItems() {
        guard let numberOfPlayers = game?.numberOfPlayers, let gameId = gameId,
            let parameters = hostParameters else {
            return
        }

        // first choose categories
        let categoryGenerator = CategoryGenerator(numberOfPlayers: numberOfPlayers,
                                                  difficultyLevel: parameters.difficultyLevel,
                                                  numOfCategories: parameters.numOfCategories)
        let categories = categoryGenerator.generateCategories()

        // allocate items according to chosen categories
        let itemsAllocator = ItemsAllocator(numberOfPlayers: numberOfPlayers,
                                            difficultyLevel: parameters.difficultyLevel,
                                            numOfPairsPerCategory: parameters.numOfPairsPerCategory)
        guard let players = game?.allPlayers else {
            return
        }
        itemsAllocator.allocateItems(categories: categories, players: players)
        gameCategories = categories

        // update other devices
        network.allocateItems(gameId: gameId, players: players)
    }

    private func initialiseOrders() {
        guard let players = game?.allPlayers, let gameId = gameId, let parameters = hostParameters else {
            return
        }
        let ordersAllocator = OrdersAllocator(difficultyLevel: parameters.difficultyLevel,
                                              maxNumOfItemsPerOrder: parameters.maxNumOfItemsPerOrder,
                                              numOfOrdersPerPlayer: parameters.numOfOrdersPerPlayer,
                                              probabilityOfSelectingOwnItem: parameters.probabilityOfSelectingOwnItem)
        ordersAllocator.allocateOrders(players: players)

        // update other devices
        network.allocateOrders(gameId: gameId, players: players)
    }

}
