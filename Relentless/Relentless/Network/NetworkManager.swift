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
        ref.child("gameIdsTaken").observeSingleEvent(of: .value, with: { (snapshot) in
            for value in snapshot.children {
                let gameIdTaken = value as? Int ?? -1
                gameIdsTaken.append(gameIdTaken)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        // randomly generate an ID and make sure it's not taken
        var gameId = Int.random(in: 1000...9999)
        while gameIdsTaken.contains(gameId) {
            gameId = Int.random(in: 1000...9999)
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
        // remove the game ID from currently taken game IDs
        var gameIdKey: String?
        ref.child("games/\(gameId)").observeSingleEvent(of: .value) { snapshot in
            let dict = snapshot.value as? [String: AnyObject] ?? [:]
            gameIdKey = dict["gameKey"] as? String
        }
        if let gameIdKey = gameIdKey {
            ref.child("gameIdsTaken/\(gameIdKey)").setValue(nil)
        }
        
        
        ref.child("games/\(gameId)").setValue(nil)
    }
    
    func joinGame(userId: String, gameId: Int) {
        ref.child("games/\(gameId)/users/\(userId)").setValue(["isInGame": true])
    }
    
    func startGame(gameId: Int) {
        // TODO
    }
    
    func sendItems(gameId: Int, items: [Item], to destination: Player) {
        // TODO: encode items
        let encodedItems = ["string"]
        
        ref.child("games/\(gameId)/users/\(destination.userId)/items").setValue(encodedItems)
    }
    
    func sendOrders(gameId: Int, orders: [Order], to destination: Player) {
        // TODO: encode orders
        let encodedOrders = ["string"]
        
        ref.child("games/\(gameId)/users/\(destination.userId)/orders").setValue(encodedOrders)
    }
    
    func receiveItems(userId: String, gameId: Int) -> [Item] {
        let path = "games/\(gameId)/users/\(userId)/items"
        var items: [Item] = []
        ref.child(path).observeSingleEvent(of: .value) { snapshot in
            items = snapshot.value as? [Item] ?? []
        }
        
        return items
    }
    
    func receiveOrders(userId: String, gameId: Int) -> [Order] {
        let path = "games/\(gameId)/users/\(userId)/orders"
        var orders: [Order] = []
        ref.child(path).observeSingleEvent(of: .value) { snapshot in
            orders = snapshot.value as? [Order] ?? []
        }
        
        return orders
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
                let packageDict = child as? NSDictionary ?? [:]
                if let package = PackageAdapter.decodePackageDictionary(dict: packageDict) {
                    action(package)
                }
            }
        })
        
        // TODO: what happens to refHandle afterwards?
    }
    
    // Deletes all the packages under a player stored in the cloud.
    // This is called after the player has received the packages.
    func deleteAllPackages(userId: String, gameId: Int) {
        ref.child("games/\(gameId)/users/\(userId)/packages").removeValue()
    }
    
}
