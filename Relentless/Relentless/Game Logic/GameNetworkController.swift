//
//  GameController.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

protocol GameNetworkController {

    func createGame(userId: String)

    func joinGame(userId: String, gameId: Int)

    func sendPackage(package: Package, to destination: Player)

    func receivePackage(package: Package)

}
