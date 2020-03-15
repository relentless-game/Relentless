//
//  ViewController.swift
//  Relentless
//
//  Created by Liu Zechu on 11/3/20.
//  Copyright © 2020 OurGroupNameIs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // test network
        // let delegate = UIApplication.shared.delegate as? AppDelegate
        // let userid = (delegate?.userId)!
        
        
        let manager = NetworkManager()
//        let userid = "myuserid"
//        let gameId = manager.createGame()
//        manager.joinGame(userId: userid, gameId: gameId)
//        let packageToSend = Package(creator: "john", packageNumber: 5, items: [])
//        let targetPlayer = Player(userId: "targeuserid", userName: "doe", profileImage: UIImage())
//        manager.sendPackage(gameId: gameId, package: packageToSend, to: targetPlayer)
        
        manager.terminateGame(gameId: 5452)
    }
    
}
