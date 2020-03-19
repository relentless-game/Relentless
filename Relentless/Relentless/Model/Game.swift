//
//  Game.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

protocol Game {

    var player: Player { get set }
    var gameId: Int { get set }
    var currentRoundNumber: Int { get set }

    var allPlayers: [Player] { get set }
    var numberOfPlayers: Int { get }

    //func addPackage(package: Package)
    func addPackage() 
    
    func removePackage(package: Package)

    func addItem(item: Item)

    func removeItem(item: Item)

    func checkPackage(package: Package, for house: House) -> Bool

    func retrieveOrders(for house: House) -> Set<Order> 

    func retrieveOrder(package: Package, house: House) -> Order?

    func addOrder(order: Order)

    func removeOrder(order: Order)

    func openPackage(package: Package)

    func incrementRoundNumber()
}
