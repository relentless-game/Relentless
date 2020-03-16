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

    private var ref: DatabaseReference!

    init() {
        ref = Database.database().reference()
    }
    
    func createGame() -> Int {
        // currently taken game IDs
        var gameIdsTaken = [Int]()
        ref.child("gameIdsTaken").observeSingleEvent(of: .value, with: { snapshot in
            for value in snapshot.children {
                let gameIdTaken = value as? Int ?? -1
                gameIdsTaken.append(gameIdTaken)
            }
        }) { error in
            print(error.localizedDescription)
        }
        
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
        
        return gameId
    }
    
    func terminateGame(gameId: Int) {
        // change game status to notify other players
        guard let gameStatus = GameStatus(isGamePlaying: false, isRoundPlaying: false,
                                          currentRound: -1).encodeToString() else {
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
    
    func joinGame(userId: String, userName: String, gameId: Int) {
        let userProfile = [
            "userId": userId,
            "userName": userName
        ]
        ref.child("games/\(gameId)/users/\(userId)").setValue(userProfile)
    }
    
    func startGame(gameId: Int) {
        guard let gameStatus = GameStatus(isGamePlaying: true, isRoundPlaying: false,
                                          currentRound: 1).encodeToString() else {
            return
        }
        ref.child("games/\(gameId)/status").setValue(gameStatus)
    }
    
    func startRound(gameId: Int, roundNumber: Int) {
        guard let gameStatus = GameStatus(isGamePlaying: true, isRoundPlaying: true,
                                          currentRound: roundNumber).encodeToString() else {
            return
        }
        ref.child("games/\(gameId)/status").setValue(gameStatus)
    }
    
    func terminateRound(gameId: Int, roundNumber: Int) {
        guard let gameStatus = GameStatus(isGamePlaying: true, isRoundPlaying: false,
                                          currentRound: roundNumber).encodeToString() else {
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
    
    // Don't use this. Use `attachItemsListener`
    func receiveItems(userId: String, gameId: Int) -> [Item] {
        let path = "games/\(gameId)/users/\(userId)/items"
        var items: [Item] = []
        ref.child(path).observeSingleEvent(of: .value) { snapshot in
            let encodedString = snapshot.value as? String ?? ""
            items = ItemsAdapter.decodeItems(from: encodedString)
        }
        
        return items
    }
    
    // Use this instead of `receiveItems`
    func attachItemsListener(userId: String, gameId: Int, action: @escaping ([Item]) -> Void) {
        let path = "games/\(gameId)/users/\(userId)/items"
        ref.child(path).observe(DataEventType.value, with: { snapshot in
            let encodedString = snapshot.value as? String ?? ""
            let items = ItemsAdapter.decodeItems(from: encodedString)

            action(items)
        })
    }
    
    // Don't use this. Use `attachOrdersListener`.
    func receiveOrders(userId: String, gameId: Int) -> [Order] {
        let path = "games/\(gameId)/users/\(userId)/orders"
        var orders: [Order] = []
        ref.child(path).observeSingleEvent(of: .value) { snapshot in
            let encodedString = snapshot.value as? String ?? ""
            orders = OrdersAdapter.decodeOrders(from: encodedString)
        }
        
        return orders
    }
    
    // Use this instead of `receiveOrders`.
    func attachOrdersListener(userId: String, gameId: Int, action: @escaping ([Order]) -> Void) {
        let path = "games/\(gameId)/users/\(userId)/orders"
        ref.child(path).observe(DataEventType.value, with: { snapshot in
            let encodedString = snapshot.value as? String ?? ""
            let orders = OrdersAdapter.decodeOrders(from: encodedString)

            action(orders)
        })
    }
    
    func sendPackage(gameId: Int, package: Package, to destination: Player) {
        let encodedPackage = PackageAdapter.encodePackage(package: package)
        ref.child("games/\(gameId)/users/\(destination.userId)/packages")
            .childByAutoId().setValue(encodedPackage)
    }
    
    func attachPackageListener(userId: String, gameId: Int, action: @escaping (Package) -> Void) {
        let path = "games/\(gameId)/users/\(userId)/packages"
        // TODO: possible problem: multiple packages added at the same time
        let refHandle = ref.child(path).observe(DataEventType.childAdded, with: { snapshot in
            for child in snapshot.children {
                let packageString = child as? String ?? ""
                if let package = PackageAdapter.decodePackage(from: packageString) {
                    action(package)
                }
            }
        })
        
        // TODO: what happens to refHandle afterwards?
    }
    
    func attachGameStatusListener(gameId: Int, action: @escaping (GameStatus) -> Void) {
        let path = "games/\(gameId)/status"
        let refHandle = ref.child(path).observe(DataEventType.value, with: { snapshot in
            let gameStatusString = snapshot.value as? String ?? ""
            guard let gameStatus = GameStatus.decodeFromString(string: gameStatusString) else {
                return
            }
            action(gameStatus)
        })
        
        // TODO: what happens to refHandle afterwards?
    }
    
    // Deletes all the packages under a player stored in the cloud.
    // This is called after the player has received the packages.
    func deleteAllPackages(userId: String, gameId: Int) {
        ref.child("games/\(gameId)/users/\(userId)/packages").removeValue()
    }
    
    // Don't use this
    func getPlayers(gameId: Int) -> [Player] {
        let path = "games/\(gameId)/users"
        var players: [Player] = []
        ref.child(path).observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children {
                let dict = child as? [String: String] ?? [:]
                let userId = dict["userId"] ?? ""
                let userName = dict["userName"] ?? ""
                let player = Player(userId: userId, userName: userName, profileImage: nil)
                players.append(player)
            }
            
        }
        
        return players
    }
    
    // Use this
    func attachPlayerJoinListener(gameId: Int, action: @escaping ([Player]) -> Void) {
        let path = "games/\(gameId)/users"
        ref.child(path).observe(.value) { snapshot in
            var players: [Player] = []
            for child in snapshot.children {
                let dict = child as? [String: String] ?? [:]
                let userId = dict["userId"] ?? ""
                let userName = dict["userName"] ?? ""
                let player = Player(userId: userId, userName: userName, profileImage: nil)
                players.append(player)
            }
            
            action(players)
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

    // TODO: change the following dummy method
    func receivePackage() -> Package {
        return Package(creator: "creator", packageNumber: 1, items: [])
    }
    
}
