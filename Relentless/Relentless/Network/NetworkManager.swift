//
//  NetworkManager.swift
//  Relentless
//
//  Created by Liu Zechu on 13/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
import Firebase

class NetworkManager: Network {

    var numOfPlayersRange: ClosedRange<Int>

    private var ref: DatabaseReference!

    init(numOfPlayersRange: ClosedRange<Int>) {
        ref = Database.database().reference()
        self.numOfPlayersRange = numOfPlayersRange
    }
    
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
    
    func terminateGame(gameId: Int, isGameEndedPrematurely: Bool) {
        // change game status to notify other players
        guard let gameStatus = GameStatus(isGamePlaying: false, isRoundPlaying: false,
                                          isGameEndedPrematurely: isGameEndedPrematurely,
                                          isPaused: false, currentRound: -1).encodeToString() else {
            return
        }
        ref.child("games/\(gameId)/status").setValue(gameStatus)
        
        // remove the game ID from currently taken game IDs
        var gameIdKey: String?
        ref.child("games/\(gameId)").observeSingleEvent(of: .value) { snapshot in
            let dict = snapshot.value as? [String: AnyObject] ?? [:]
            gameIdKey = dict["gameKey"] as? String
            
            // remove the game ID from currently taken game IDs
            if let gameIdKey = gameIdKey {
                self.ref.child("gameIdsTaken/\(gameIdKey)").setValue(nil)
            }
            
            // remove the game room
            self.ref.child("games/\(gameId)").setValue(nil)
        }
    }
        
    func joinGame(userId: String, userName: String, gameId: Int, completion: @escaping (JoinGameError?) -> Void) {
        // series of chained checks
        // game ID validity -> game already playing -> game room full
        checkGameIdValidity(userId: userId, userName: userName, gameId: gameId, completion: completion)
    }
    
    private func checkGameIdValidity(userId: String, userName: String, gameId: Int,
                                     completion: @escaping (JoinGameError?) -> Void) {
        ref.child("gameIdsTaken").observeSingleEvent(of: .value) { snapshot in
            var gameIdsTaken = [Int]()
            if let snapDict = snapshot.value as? [String: Int] {
                for gameId in snapDict.values {
                    gameIdsTaken.append(gameId)
                }
            }
            let isGameIdValid = gameIdsTaken.contains(gameId)
            if isGameIdValid {
                // next check
                self.checkGameAlreadyPlaying(userId: userId, userName: userName, gameId: gameId, completion: completion)
            } else {
                completion(JoinGameError.invalidGameId)
            }
        }
    }
    
    private func checkGameAlreadyPlaying(userId: String, userName: String, gameId: Int,
                                         completion: @escaping (JoinGameError?) -> Void) {
        ref.child("games/\(gameId)/status").observeSingleEvent(of: .value) { snapshot in
            let statusString = snapshot.value as? String ?? ""
            if let gameStatus = GameStatus.decodeFromString(string: statusString) {
                let isGameStarted = gameStatus.isGamePlaying
                if isGameStarted {
                    completion(JoinGameError.gameAlreadyPlaying)
                } else {
                    // next check
                    self.checkGameRoomFull(userId: userId, userName: userName, gameId: gameId, completion: completion)
                }
            }
        }
    }
    
    private func checkGameRoomFull(userId: String, userName: String, gameId: Int,
                                   completion: @escaping (JoinGameError?) -> Void) {
        ref.child("games/\(gameId)/users").observeSingleEvent(of: .value) { snapshot in
            var numberOfPlayers = 0
            for _ in snapshot.children {
                numberOfPlayers += 1
            }
            let maxNumOfPlayers = self.numOfPlayersRange.upperBound
            if numberOfPlayers < maxNumOfPlayers {
                self.joinGameInDatabase(userId: userId, userName: userName, gameId: gameId)
                completion(nil) // nil indicates successful result
            } else {
                completion(JoinGameError.gameRoomFull)
            }
        }
    }
    
    private func joinGameInDatabase(userId: String, userName: String, gameId: Int) {
        // add this user to the game
        let userProfile = [
            "userId": userId,
            "userName": userName
        ]
        ref.child("games/\(gameId)/users/\(userId)").setValue(userProfile)
    }
    
    func editUserInfo(userId: String, gameId: Int, username: String, profile: PlayerAvatar) {
        let userProfile = [
            "userId": userId,
            "userName": username,
            "profile": profile.rawValue
        ]
        ref.child("games/\(gameId)/users/\(userId)").setValue(userProfile)
    }
    
    func quitGame(userId: String, gameId: Int) {
        ref.child("games/\(gameId)/users/\(userId)").setValue(nil)
    }
    
    func startGame(gameId: Int, gameParameters: GameParameters, completion: @escaping (StartGameError?) -> Void) {
        // enough players -> start game
        checkEnoughPlayers(gameId: gameId, gameParameters: gameParameters, completion: completion)
    }

    private func checkEnoughPlayers(gameId: Int, gameParameters: GameParameters,
                                    completion: @escaping (StartGameError?) -> Void) {
        ref.child("games/\(gameId)/users").observeSingleEvent(of: .value) { snapshot in
            var numberOfPlayers = 0
            for _ in snapshot.children {
                numberOfPlayers += 1
            }
            let minNumOfPlayers = self.numOfPlayersRange.lowerBound
            if numberOfPlayers >= minNumOfPlayers {
                self.startGameInDatabase(gameId: gameId, gameParameters: gameParameters)
                completion(nil) // nil indicates successful result
            } else {
                completion(StartGameError.insufficientPlayers)
            }
        }
    }

    private func startGameInDatabase(gameId: Int, gameParameters: GameParameters) {
        guard let gameStatus = GameStatus(isGamePlaying: true, isRoundPlaying: false,
                                          isGameEndedPrematurely: false,
                                          isPaused: false, currentRound: 0).encodeToString() else {
            return
        }
        ref.child("games/\(gameId)/status").setValue(gameStatus)
        ref.child("games/\(gameId)/gameParameters").setValue(gameParameters)
    }

    func startRound(gameId: Int, roundNumber: Int) {
        guard let gameStatus = GameStatus(isGamePlaying: true, isRoundPlaying: true, isGameEndedPrematurely: false,
                                          isPaused: false, currentRound: roundNumber).encodeToString() else {
            return
        }
        ref.child("games/\(gameId)/status").setValue(gameStatus)
    }
    
    func terminateRound(gameId: Int, roundNumber: Int) {
        guard let gameStatus = GameStatus(isGamePlaying: true, isRoundPlaying: false, isGameEndedPrematurely: false,
                                          isPaused: false, currentRound: roundNumber).encodeToString() else {
            return
        }
        ref.child("games/\(gameId)/status").setValue(gameStatus)
    }
    
    func sendItems(gameId: Int, items: [Item], to destination: Player) {
        guard let encodedItems = ItemsAdapter.encodeItems(items: items) else {
            return
        }
        
        ref.child("games/\(gameId)/users/\(destination.userId)/items").setValue(encodedItems)
    }
    
    func sendOrders(gameId: Int, orders: [Order], to destination: Player) {
        guard let encodedOrders = OrdersAdapter.encodeOrders(orders: orders) else {
            return
        }
        
        ref.child("games/\(gameId)/users/\(destination.userId)/orders").setValue(encodedOrders)
    }
    
    func attachItemsListener(userId: String, gameId: Int, action: @escaping ([Item]) -> Void) {
        let path = "games/\(gameId)/users/\(userId)/items"
        ref.child(path).observe(DataEventType.value, with: { snapshot in
            let encodedString = snapshot.value as? String ?? ""
            let items = ItemsAdapter.decodeItems(from: encodedString)

            action(items)
        })
    }
    
    func attachOrdersListener(userId: String, gameId: Int, action: @escaping ([Order]) -> Void) {
        let path = "games/\(gameId)/users/\(userId)/orders"
        ref.child(path).observe(DataEventType.value, with: { snapshot in
            let encodedString = snapshot.value as? String ?? ""
            let orders = OrdersAdapter.decodeOrders(from: encodedString)

            if !orders.isEmpty {
                action(orders)
            }
        })
    }
    
    func sendPackage(gameId: Int, package: Package, to destination: Player) {
        let encodedPackage = PackageAdapter.encodePackage(package: package)
        ref.child("games/\(gameId)/users/\(destination.userId)/packages")
            .childByAutoId().setValue(encodedPackage)
    }
    
    func attachPackageListener(userId: String, gameId: Int, action: @escaping (Package) -> Void) {
        let path = "games/\(gameId)/users/\(userId)/packages"
        _ = ref.child(path).observe(DataEventType.childAdded, with: { snapshot in
            let packageString = snapshot.value as? String ?? ""
            if let package = PackageAdapter.decodePackage(from: packageString) {
                action(package)
            }
        })
        
    }
    
    func attachGameStatusListener(gameId: Int, action: @escaping (GameStatus) -> Void) {
        let path = "games/\(gameId)/status"
        _ = ref.child(path).observe(DataEventType.value, with: { snapshot in
            let gameStatusString = snapshot.value as? String ?? ""
            guard let gameStatus = GameStatus.decodeFromString(string: gameStatusString) else {
                return
            }
            action(gameStatus)
        })
        
    }
    
    // Deletes all the packages under a player stored in the cloud.
    // This is called after the player has received the packages.
    func deleteAllPackages(userId: String, gameId: Int) {
        ref.child("games/\(gameId)/users/\(userId)/packages").removeValue()
    }
    
    func attachPlayerJoinListener(gameId: Int, action: @escaping ([Player]) -> Void) {
        let path = "games/\(gameId)/users"
        ref.child(path).observe(.value) { snapshot in
            var players: [Player] = []
            if let dict = snapshot.value as? [String: [String: Any]] {
                for playerInfo in dict.values {
                    let userId = playerInfo["userId"] as? String ?? ""
                    let userName = playerInfo["userName"] as? String ?? ""
                    let userProfileString = playerInfo["profile"] as? String ?? ""
                    let userProfileAvatar = PlayerAvatar(rawValue: userProfileString)
                    let player = Player(userId: userId, userName: userName, profileImage: userProfileAvatar)
                    players.append(player)
                }
            }
            action(players) // all the players currently in the game
        }
    }
    
    func allocateItems(gameId: Int, players: [Player]) {
        for player in players {
            sendItems(gameId: gameId, items: Array(player.items), to: player)
        }
    }

    func allocateOrders(gameId: Int, players: [Player]) {
        for player in players {
            sendOrders(gameId: gameId, orders: Array(player.orders), to: player)
        }
    }
        
    func pauseRound(gameId: Int, currentRound: Int) {
        guard let gameStatus = GameStatus(isGamePlaying: true, isRoundPlaying: true, isGameEndedPrematurely: false,
                                          isPaused: true, currentRound: currentRound).encodeToString() else {
            return
        }
        ref.child("games/\(gameId)/status").setValue(gameStatus)
    }

    func resumeRound(gameId: Int, currentRound: Int) {
        guard let gameStatus = GameStatus(isGamePlaying: true, isRoundPlaying: true, isGameEndedPrematurely: false,
                                          isPaused: false, currentRound: currentRound,
                                          isResumed: true).encodeToString() else {
            return
        }
        ref.child("games/\(gameId)/status").setValue(gameStatus)
        // reset pause countdown
        updatePauseCountDown(gameId: gameId, countDown: 30)
    }
    
    func updateIndividualSatisfactionLevel(gameId: Int, userId: String, satisfactionLevel: Float) {
        ref.child("games/\(gameId)/satisfactionLevel/\(userId)").setValue(satisfactionLevel)
    }

    func resetSatisfactionLevels(gameId: Int) {
        ref.child("games/\(gameId)/satisfactionLevel").setValue(nil)
    }
    
    func attachTeamSatisfactionListener(gameId: Int, action: @escaping ([Float]) -> Void) {
        let path = "games/\(gameId)/satisfactionLevel"
        ref.child(path).observe(.value) { snapshot in
            let snapDict = snapshot.value as? [String: Float] ?? [:]
            let satisfactionLevels = Array(snapDict.values)
            action(satisfactionLevels)
        }
    }
    
    func outOfOrders(userId: String, gameId: Int) {
        ref.child("games/\(gameId)/playersOutOfOrders/\(userId)").setValue(true)
    }
    
    func attachOutOfOrdersListener(gameId: Int, action: @escaping (Int) -> Void) {
        let path = "games/\(gameId)/playersOutOfOrders"
        ref.child(path).observe(.value) { snapshot in
            if let snapDict = snapshot.value as? [String: Bool] {
                let playersOutOfOrders = snapDict.values
                action(playersOutOfOrders.count)
            }
        }
    }
    
    func resetPlayersOutOfOrders(gameId: Int) {
        ref.child("games/\(gameId)/playersOutOfOrders").setValue(nil)
    }
    
    // this is currently used for pausing/resuming a game
    func updateGameStatus(gameId: Int, gameStatus: GameStatus) {
        let gameStatusString = gameStatus.encodeToString()
        ref.child("games/\(gameId)/status").setValue(gameStatusString)
    }
    
    func attachPauseCountDownListener(gameId: Int, action: @escaping (Int) -> Void) {
        let path = "games/\(gameId)/countdown"
        _ = ref.child(path).observe(DataEventType.value, with: { snapshot in
            let countdown = snapshot.value as? Int ?? 30
            action(countdown)
        })
    }
    
    func updatePauseCountDown(gameId: Int, countDown: Int) {
        ref.child("games/\(gameId)/countdown").setValue(countDown)
    }

    func setPackageItemsLimit(gameId: Int, limit: Int) {
        ref.child("games/\(gameId)/packageItemsLimit").setValue(limit)
    }

    func attachPackageItemsLimitListener(gameId: Int, action: @escaping (Int?) -> Void) {
        let path = "games/\(gameId)/packageItemsLimit"
        _ = ref.child(path).observe(DataEventType.value, with: { snapshot in
            let packageItemsLimit = snapshot.value as? Int
            action(packageItemsLimit)
        })
    }

    func attachGameParametersListener(gameId: Int, action: @escaping (GameParameters) -> Void) {
        let path = "games/\(gameId)/gameParameters"
        _ = ref.child(path).observe(DataEventType.value, with: { snapshot in
            if let gameParameters = snapshot.value as? GameParameters {
                action(gameParameters)
            }
        })
    }
}
