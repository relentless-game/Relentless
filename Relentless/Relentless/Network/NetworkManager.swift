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
        // TODO: change how game id is generated
        let gameId = Int.random(in: 1000...9999)
        ref.child("games").child("\(gameId)").setValue(["gameId": gameId])
        
        return gameId
    }
    
    func terminateGame(gameId: Int) {
        ref.child("games/\(gameId)").setValue(nil)
    }
    
    func joinGame(userId: String, gameId: Int) -> Bool {
        ref.child("games/\(gameId)/users/\(userId)").setValue(["isInGame": true])
        
        return true
    }
    
    func sendPackage(gameId: Int, package: Package, to destination: Player) -> Bool {
        ref.child("games/\(gameId)/users/\(destination.userId)").setValue(["packages": package.index])
        
        return true
    }
    
    func receivePackage(userId: String, gameId: Int, action: @escaping (Package) -> Void) {
        let refHandle = ref.child("games/\(gameId)/users/\(userId)").observe(DataEventType.value, with: { (snapshot) in
            let userDict = snapshot.value as? [String : AnyObject] ?? [:]
            let packageIndex = userDict["packages"] as? Int ?? -1
            let package = Package(index: packageIndex)
            action(package)
        })
    }
    
}
