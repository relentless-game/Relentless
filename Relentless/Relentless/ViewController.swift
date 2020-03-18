//
//  ViewController.swift
//  Relentless
//
//  Created by Liu Zechu on 11/3/20.
//  Copyright © 2020 OurGroupNameIs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // To obtain the unique user ID given by Firebase upon launching the app
    let delegate = UIApplication.shared.delegate as? AppDelegate
    var userId: String!
    var gameController: GameController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // To obtain the unique user ID given by Firebase upon launching the app
        if let delegate = delegate {
            userId = delegate.userId
        }

        // Initialise game controller
        //gameController = GameControllerManager(userId: userId)
        // ...
        
        let manager = NetworkManager()
        let userid = "myuserid"
        manager.createGame { gameId in
            print("the new game ID is \(gameId)")
        }
//        let gameId = manager.createGame()
//        do {
//            try manager.joinGame(userId: userid, userName: "hi", gameId: gameId)
//        } catch {
//
//        }
//        let packageToSend = Package(creator: "john", packageNumber: 5, items: [])
//        let targetPlayer = Player(userId: "targeuserid", userName: "doe", profileImage: UIImage())
//        manager.sendPackage(gameId: gameId, package: packageToSend, to: targetPlayer)
    }
    
}
