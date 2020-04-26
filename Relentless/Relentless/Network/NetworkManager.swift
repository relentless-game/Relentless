//
//  NetworkManager.swift
//  Relentless
//
//  Created by Liu Zechu on 13/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
import Firebase

/// This is the implementation class of the `Network` protocol which handles the networking component
/// in charge of communication of information between different players in the game, using Firebase.
class NetworkManager: Network {

    internal var ref: DatabaseReference!
    
    init() {
        ref = Database.database().reference()
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
        
    func joinGame(userId: String, userName: String, avatar: PlayerAvatar, gameId: Int,
                  completion: @escaping (JoinGameError?) -> Void) {
        // series of chained checks
        // game ID validity -> game already playing -> game room full
        checkGameIdValidity(userId: userId, userName: userName, avatar: avatar, gameId: gameId, completion: completion)
    }
    
    private func checkGameIdValidity(userId: String, userName: String, avatar: PlayerAvatar, gameId: Int,
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
                self.checkGameAlreadyPlaying(userId: userId, userName: userName, avatar: avatar,
                                             gameId: gameId, completion: completion)
            } else {
                completion(JoinGameError.invalidGameId)
            }
        }
    }
    
    private func checkGameAlreadyPlaying(userId: String, userName: String, avatar: PlayerAvatar, gameId: Int,
                                         completion: @escaping (JoinGameError?) -> Void) {
        ref.child("games/\(gameId)/status").observeSingleEvent(of: .value) { snapshot in
            let statusString = snapshot.value as? String ?? ""
            if let gameStatus = GameStatus.decodeFromString(string: statusString) {
                let isGameStarted = gameStatus.isGamePlaying
                if isGameStarted {
                    completion(JoinGameError.gameAlreadyPlaying)
                } else {
                    // next check
                    self.checkGameRoomFull(userId: userId, userName: userName, avatar: avatar,
                                           gameId: gameId, completion: completion)
                }
            }
        }
    }
    
    private func checkGameRoomFull(userId: String, userName: String, avatar: PlayerAvatar, gameId: Int,
                                   completion: @escaping (JoinGameError?) -> Void) {
        ref.child("games/\(gameId)/users").observeSingleEvent(of: .value) { snapshot in
            var numberOfPlayers = 0
            for _ in snapshot.children {
                numberOfPlayers += 1
            }

            self.ref.child("games/\(gameId)/maxNumOfPlayers").observeSingleEvent(of: .value) { snapshot in
                let maxNumOfPlayers = snapshot.value as? Int ?? 6
                if numberOfPlayers < maxNumOfPlayers {
                    self.joinGameInDatabase(userId: userId, userName: userName, avatar: avatar, gameId: gameId)
                    completion(nil) // nil indicates successful result
                } else {
                    completion(JoinGameError.gameRoomFull)
                }
            }
        }
    }
    
    private func joinGameInDatabase(userId: String, userName: String, avatar: PlayerAvatar, gameId: Int) {
        // add this user to the game
        let userProfile = [
            "userId": userId,
            "userName": userName,
            "profile": avatar.rawValue
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

    func terminateRound(gameId: Int, roundNumber: Int) {
        guard let gameStatus = GameStatus(isGamePlaying: true, isRoundPlaying: false, isGameEndedPrematurely: false,
                                          isPaused: false, currentRound: roundNumber).encodeToString() else {
            return
        }
        ref.child("games/\(gameId)/status").setValue(gameStatus)
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
                    guard let userProfileAvatar = PlayerAvatar(rawValue: userProfileString) else {
                        return
                    }
                    let player = Player(userId: userId, userName: userName, profileImage: userProfileAvatar)
                    players.append(player)
                }
            }
            action(players) // all the players currently in the game
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
    
    func updateIndividualSatisfactionLevel(gameId: Int, userId: String, satisfactionLevel: Double) {
        ref.child("games/\(gameId)/satisfactionLevel/\(userId)").setValue(satisfactionLevel)
    }

    func resetSatisfactionLevels(gameId: Int) {
        ref.child("games/\(gameId)/satisfactionLevel").setValue(nil)
    }
    
    func attachTeamSatisfactionListener(gameId: Int, action: @escaping ([Float]) -> Void) {
        let path = "games/\(gameId)/satisfactionLevel"
        ref.child(path).observe(.value) { snapshot in
            let snapDict = snapshot.value as? [String: Double] ?? [:]
            let satisfactionLevels = Array(snapDict.values).map { Float($0) }
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

    func attachPackageItemsLimitListener(gameId: Int, action: @escaping (Int?) -> Void) {
        let path = "games/\(gameId)/packageItemsLimit"
        _ = ref.child(path).observe(DataEventType.value, with: { snapshot in
            let packageItemsLimit = snapshot.value as? Int
            action(packageItemsLimit)
        })
    }

    func attachConfigValuesListener(gameId: Int, action: @escaping (LocalConfigValues) -> Void) {
        let path = "games/\(gameId)/configValues"
        _ = ref.child(path).observe(DataEventType.value, with: { snapshot in
            let configValuesString = snapshot.value as? String ?? ""
            if let configValues = LocalConfigValues.decodeFromString(string: configValuesString) {
                action(configValues)
            }
        })
    }

    func attachItemSpecificationsListener(userId: String, gameId: Int,
                                          action: @escaping (RoundItemSpecifications) -> Void) {
        let path = "games/\(gameId)/roundItemSpecifications"
        _ = ref.child(path).observe(DataEventType.value, with: { snapshot in
            let roundItemSpecsString = snapshot.value as? String ?? ""
            if let roundItemSpecs = RoundItemSpecifications.decodeFromString(string: roundItemSpecsString) {
                action(roundItemSpecs)
            }
        })
    }

}
