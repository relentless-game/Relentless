//
//  HostNetworkManager.swift
//  Relentless
//
//  Created by Yi Wai Chow on 25/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// This is the implementation class of `HostNetwork`
/// which handles networking communication from the host to the other players.
class HostNetworkManager: NetworkManager, HostNetwork {

    func createGame(completion: @escaping (Int) -> Void) {
        ref.child("gameIdsTaken").observeSingleEvent(of: .value) { snapshot in
            var gameIdsTaken = [Int]()
            if let snapDict = snapshot.value as? [String: Int] {
                for gameId in snapDict.values {
                    gameIdsTaken.append(gameId)
                }
            }
            self.createGameInDatabase(gameIdsTaken: gameIdsTaken, completion: completion)
        }
    }

    func startGame(gameId: Int, configValues: LocalConfigValues, completion: @escaping (StartGameError?) -> Void) {
        // enough players -> start game
        checkEnoughPlayers(gameId: gameId, configValues: configValues, completion: completion)
    }

    func startRound(gameId: Int, roundNumber: Int) {
        guard let gameStatus = GameStatus(isGamePlaying: true, isRoundPlaying: true, isGameEndedPrematurely: false,
                                          isPaused: false, currentRound: roundNumber).encodeToString() else {
            return
        }
        ref.child("games/\(gameId)/status").setValue(gameStatus)
    }

    func allocateItems(gameId: Int, players: [Player]) {
        for player in players {
            sendItems(gameId: gameId, items: Array(player.items), to: player)
        }
    }

    func allocateOrders(gameId: Int, players: [Player]) {
        for player in players {
            sendOrders(gameId: gameId, orders: Array(player.orders), to: player)
            clearOrders(gameId: gameId, player: player)
        }
    }

    func setPackageItemsLimit(gameId: Int, limit: Int) {
        ref.child("games/\(gameId)/packageItemsLimit").setValue(limit)
    }

    func broadcastRoundItemSpecification(gameId: Int, roundItemSpecification: RoundItemSpecifications) {
        let path = "games/\(gameId)/roundItemSpecifications"
        guard let roundItemSpecs = roundItemSpecification.encodeToString() else {
            return
        }
        ref.child(path).setValue(roundItemSpecs)
    }

    func initialiseNumberOfPlayersRange(gameId: Int, min: Int, max: Int) {
        ref.child("games/\(gameId)/minNumOfPlayers").setValue(min)
        ref.child("games/\(gameId)/maxNumOfPlayers").setValue(max)
    }

    private func createGameInDatabase(gameIdsTaken: [Int], completion: @escaping (Int) -> Void) {
        // randomly generate an ID and make sure it's not taken
        var gameId = Int.random(in: 1_000...9_999)
        while gameIdsTaken.contains(gameId) {
            gameId = Int.random(in: 1_000...9_999)
        }

        // add this ID to currently taken game IDs
        let gameIdNode = ref.child("gameIdsTaken").childByAutoId()
        gameIdNode.setValue(gameId)
        let gameIdKey = gameIdNode.key ?? "key"

        // create a game room
        ref.child("games").child("\(gameId)").setValue(["gameKey": gameIdKey])

        // initialise game status
        if let gameStatus = GameStatus(isGamePlaying: false, isRoundPlaying: false,
                                       isGameEndedPrematurely: false,
                                       isPaused: false, currentRound: 0).encodeToString() {
            ref.child("games/\(gameId)/status").setValue(gameStatus)
        }

        // notify game controller about the game ID
        completion(gameId)
    }

    private func checkEnoughPlayers(gameId: Int, configValues: LocalConfigValues,
                                    completion: @escaping (StartGameError?) -> Void) {
        ref.child("games/\(gameId)/users").observeSingleEvent(of: .value) { snapshot in
            var numberOfPlayers = 0
            for _ in snapshot.children {
                numberOfPlayers += 1
            }

            self.ref.child("games/\(gameId)/minNumOfPlayers").observeSingleEvent(of: .value) { snapshot in
                let minNumOfPlayers = snapshot.value as? Int ?? 3
                if numberOfPlayers >= minNumOfPlayers {
                    self.startGameInDatabase(gameId: gameId, configValues: configValues)
                    completion(nil) // nil indicates successful result
                } else {
                    completion(StartGameError.insufficientPlayers)
                }
            }
        }
    }

    private func startGameInDatabase(gameId: Int, configValues: LocalConfigValues) {
        guard let gameStatus = GameStatus(isGamePlaying: true, isRoundPlaying: false,
                                          isGameEndedPrematurely: false,
                                          isPaused: false, currentRound: 0).encodeToString() else {
            return
        }
        ref.child("games/\(gameId)/status").setValue(gameStatus)
        guard let localConfigValues = configValues.encodeToString() else {
            return
        }
        ref.child("games/\(gameId)/configValues").setValue(localConfigValues)
    }

    private func sendItems(gameId: Int, items: [Item], to destination: Player) {
        guard let encodedItems = ItemsAdapter.encodeItems(items: items) else {
            return
        }

        ref.child("games/\(gameId)/users/\(destination.userId)/items").setValue(encodedItems)
    }

    private func sendOrders(gameId: Int, orders: [Order], to destination: Player) {
        guard let encodedOrders = OrdersAdapter.encodeOrders(orders: orders) else {
            return
        }

        ref.child("games/\(gameId)/users/\(destination.userId)/orders").setValue(encodedOrders)
    }
    
    private func clearOrders(gameId: Int, player: Player) {
        ref.child("games/\(gameId)/users/\(player.userId)/orders").setValue(nil)
    }

}
